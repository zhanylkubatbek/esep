import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/local/calculation_store.dart';
import '../../../../data/models/calculation_record.dart';
import '../../../../data/models/farm_model.dart';
import '../../../../data/normatives/normatives.dart';
import '../../../../data/remote/solver_api.dart';
import '../../domain/farm_type.dart';
import 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit({
    required this.normatives,
    required this.solver,
    required this.store,
  }) : super(const CalculatorState());

  final Normatives normatives;
  final FarmSolver solver;
  final CalculationStore store;

  /// Запись текущего расчёта в хранилище — нужна для экспорта в PDF
  /// и для связи экрана результата с историей.
  CalculationRecord? get currentRecord {
    final id = state.currentRecordId;
    if (id == null) return null;
    for (final record in store.readAll()) {
      if (record.id == id) return record;
    }
    return null;
  }

  /// Породы, дающие хотя бы один из запланированных видов продукции.
  /// Без такой проверки пользователь может выбрать только мясные породы
  /// при плане по молоку и получить непонятное «решение не найдено».
  bool get selectedBreedsCoverPlan {
    final plannedProducts = state.productionPlan.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toSet();
    final coveredProducts = normatives.breedProducts
        .where((bp) => state.selectedBreedIds.contains(bp.breedId))
        .map((bp) => bp.productId)
        .toSet();
    return plannedProducts.every(coveredProducts.contains);
  }

  /// Виды продукции из плана, которые не даёт ни одна выбранная порода.
  /// Возвращаются идентификаторы: название на нужном языке подставит экран.
  List<String> get uncoveredProductIds {
    final covered = normatives.breedProducts
        .where((bp) => state.selectedBreedIds.contains(bp.breedId))
        .map((bp) => bp.productId)
        .toSet();
    return state.productionPlan.entries
        .where((e) => e.value > 0 && !covered.contains(e.key))
        .map((e) => e.key)
        .toList();
  }

  /// Проверка правдоподобия до расчёта: 3000 т молока с 320 га — скорее
  /// всего перепутаны литры и тонны. Возвращает предупреждения, но не
  /// запрещает продолжить.
  List<PlausibilityWarning> get plausibilityWarnings {
    if (!state.hasLand) return const [];
    final warnings = <PlausibilityWarning>[];
    for (final entry in state.productionPlan.entries) {
      if (entry.value <= 0) continue;
      final limit = normatives.plausibilityLimitFor(entry.key);
      if (limit == null) continue;
      final maxReasonable = limit * state.totalLandHa;
      if (entry.value > maxReasonable) {
        warnings.add(PlausibilityWarning(
          entry.key,
          state.totalLandHa,
          maxReasonable,
        ));
      }
    }
    return warnings;
  }

  void setFarmType(FarmType type) => emit(state.copyWith(farmType: type));

  void setLandArea(String landId, double? hectares) {
    final areas = Map.of(state.landAreas);
    if (hectares == null || hectares <= 0) {
      areas.remove(landId);
    } else {
      areas[landId] = hectares;
    }
    emit(state.copyWith(landAreas: areas));
  }

  void setProductionPlan(String productId, double? tons) {
    final plan = Map.of(state.productionPlan);
    if (tons == null || tons <= 0) {
      plan.remove(productId);
    } else {
      plan[productId] = tons;
    }
    emit(state.copyWith(productionPlan: plan));
  }

  void toggleBreed(String breedId) {
    final ids = Set.of(state.selectedBreedIds);
    final limits = Map.of(state.breedLimits);
    if (ids.remove(breedId)) {
      // Снятая порода уносит с собой и свой предел: оставленное
      // число всплыло бы при повторном выборе как чужая настройка.
      limits.remove(breedId);
    } else {
      ids.add(breedId);
    }
    emit(state.copyWith(selectedBreedIds: ids, breedLimits: limits));
  }

  /// Предел поголовья породы — n[l] из (1.7). null или ноль снимает
  /// ограничение: «не ограничиваю» и «ноль голов» для хозяйства
  /// разные вещи, и вторую нельзя получить случайной очисткой поля.
  void setBreedLimit(String breedId, double? heads) {
    final limits = Map.of(state.breedLimits);
    if (heads == null || heads <= 0) {
      limits.remove(breedId);
    } else {
      limits[breedId] = heads;
    }
    emit(state.copyWith(breedLimits: limits));
  }

  /// Собирает запрос: пользовательские данные + нормативы института.
  ///
  /// Породы — только выбранные. Культуры — все, а не только растущие
  /// на угодьях хозяйства: культура, которую негде посеять, остаётся
  /// в задаче как строка кормового баланса (1.3) и как кандидат на
  /// закупку. Если её выбросить, вместе с ней пропадёт и потребность
  /// стада в этом корме — хозяйство без пастбищ получило бы
  /// пастбищный корм даром.
  OptimizationInput buildInput() {
    final landAreas = state.landAreas;
    final landIds = landAreas.keys.toSet();

    final lands = normatives.lands
        .where((l) => landIds.contains(l.id))
        .map((l) =>
            LandCategory(id: l.id, name: l.name, areaHa: landAreas[l.id]!))
        .toList();

    final crops = normatives.crops
        .map((c) => Crop(
              id: c.id,
              name: c.name,
              yieldByLand: {
                for (final e in c.yieldByLand.entries)
                  if (landIds.contains(e.key)) e.key: e.value,
              },
              costByLand: {
                for (final e in c.costByLand.entries)
                  if (landIds.contains(e.key)) e.key: e.value,
              },
              purchasePricePerTon: c.purchasePricePerTon,
            ))
        .toList();

    final breedProducts = normatives.breedProducts
        .where((bp) => state.selectedBreedIds.contains(bp.breedId))
        .where((bp) => (state.productionPlan[bp.productId] ?? 0) > 0)
        .toList();

    return OptimizationInput(
      lands: lands,
      crops: crops,
      breedProducts: breedProducts,
      productionPlan: Map.of(state.productionPlan)
        ..removeWhere((_, v) => v <= 0),
      breedLimits: {
        for (final e in state.breedLimits.entries)
          if (state.selectedBreedIds.contains(e.key) && e.value > 0) e.key: e.value,
      },
      normativesVersion: normatives.version,
    );
  }

  /// Считает на устройстве и сохраняет результат.
  ///
  /// Раньше запись создавалась заранее, «в очереди», чтобы не потерять
  /// ввод при обрыве связи. Теперь расчёт идёт локально и занимает
  /// миллисекунды, поэтому запись создаётся один раз — уже с исходом.
  Future<void> runCalculation() async {
    emit(state.copyWith(
      phase: CalculationPhase.solving,
      clearResult: true,
      clearFailure: true,
    ));

    final input = buildInput();
    OptimizationResult? solved;
    SolverException? failure;
    RecordStatus status;

    try {
      solved = await solver.solve(input);
      status = solved.status == SolveStatus.optimal
          ? RecordStatus.done
          : RecordStatus.infeasible;
    } on SolverException catch (e) {
      failure = e;
      status = RecordStatus.failed;
    }

    final record = CalculationRecord(
      id: 'calc-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
      input: input,
      status: status,
      normativesVersion: normatives.version,
      farmTypeId: state.farmType?.name,
      result: solved,
      solverVersion: solved?.solverVersion,
    );
    await store.save(record);

    emit(state.copyWith(
      phase: failure == null ? CalculationPhase.done : CalculationPhase.failed,
      result: solved,
      failure: failure,
      currentRecordId: record.id,
    ));
  }

  void reset() => emit(const CalculatorState());

  /// Открывает сохранённый расчёт: восстанавливает и ввод, и результат,
  /// чтобы экраны рекомендации и «как это посчитано» работали так же,
  /// как сразу после расчёта.
  void loadRecord(CalculationRecord record) {
    emit(CalculatorState(
      farmType: FarmType.values
          .where((t) => t.name == record.farmTypeId)
          .firstOrNull,
      landAreas: {
        for (final l in record.input.lands) l.id: l.areaHa,
      },
      productionPlan: Map.of(record.input.productionPlan),
      selectedBreedIds:
          record.input.breedProducts.map((bp) => bp.breedId).toSet(),
      breedLimits: Map.of(record.input.breedLimits),
      phase: record.result == null
          ? CalculationPhase.input
          : CalculationPhase.done,
      result: record.result,
      currentRecordId: record.id,
    ));
  }
}
