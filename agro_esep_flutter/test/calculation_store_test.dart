import 'package:agro_esep/data/local/calculation_store.dart';
import 'package:agro_esep/data/models/calculation_record.dart';
import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/data/remote/solver_api.dart';
import 'package:agro_esep/features/calculator/domain/farm_type.dart';
import 'package:agro_esep/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_normatives.dart';

/// Решатель, которым управляет тест: можно заставить его падать
/// «без связи», а потом «починить».
class _ControllableSolver implements FarmSolver {
  SolverFailureKind? failWith;
  int solveCalls = 0;

  @override
  Future<OptimizationResult> solve(OptimizationInput input) async {
    solveCalls++;
    if (failWith != null) throw SolverException(failWith!);
    return const OptimizationResult(
      status: SolveStatus.optimal,
      totalCost: 1000,
      solverVersion: 'stub-1',
    );
  }
}

CalculatorCubit _controller(_ControllableSolver solver, CalculationStore store) {
  return CalculatorCubit(
    normatives: buildTestNormatives(),
    solver: solver,
    store: store,
  )
    ..setLandArea('irrigated', 120)
    ..setProductionPlan('milk', 100)
    ..toggleBreed('alatau');
}

void main() {
  group('сериализация записи', () {
    test('запись переживает круг json -> объект без потерь', () {
      final original = CalculationRecord(
        id: 'calc-1',
        createdAt: DateTime.utc(2026, 8, 8, 9, 44),
        input: OptimizationInput(
          lands: const [LandCategory(id: 'irrigated', name: 'Орошаемая', areaHa: 120)],
          crops: const [
            Crop(
              id: 'alfalfa',
              name: 'Люцерна',
              yieldByLand: {'irrigated': 8},
              costByLand: {'irrigated': 15000},
            ),
          ],
          breedProducts: const [
            BreedProduct(
              breedId: 'alatau',
              breedName: 'Алатауская',
              productId: 'milk',
              productName: 'Молоко',
              yieldPerHead: 4.2,
              annualCostPerHead: 45000,
              feedNeed: {'alfalfa': 2.0},
            ),
          ],
          productionPlan: const {'milk': 100},
          normativesVersion: 'test-1.0',
        ),
        status: RecordStatus.done,
        normativesVersion: 'test-1.0',
        farmTypeId: 'peasant',
        result: const OptimizationResult(
          status: SolveStatus.optimal,
          totalCost: 5542462,
          cropArea: [
            CropAreaAllocation(landId: 'irrigated', cropId: 'alfalfa', areaHa: 25.56),
          ],
          livestock: [
            LivestockAllocation(breedId: 'alatau', productId: 'milk', heads: 72),
          ],
          solverVersion: 'scipy-milp-highs',
        ),
        solverVersion: 'scipy-milp-highs',
      );

      final restored = CalculationRecord.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.createdAt, original.createdAt);
      expect(restored.status, RecordStatus.done);
      expect(restored.normativesVersion, 'test-1.0');
      expect(restored.farmTypeId, 'peasant');
      expect(restored.result!.totalCost, 5542462);
      expect(restored.result!.livestock.single.heads, 72);
      expect(restored.result!.cropArea.single.areaHa, 25.56);
      expect(restored.input.lands.single.areaHa, 120);
      expect(restored.totalHeads, 72);
    });

    test('запись без результата сериализуется', () {
      final queued = CalculationRecord(
        id: 'calc-2',
        createdAt: DateTime.utc(2026, 8, 8),
        input: OptimizationInput(
          lands: const [LandCategory(id: 'irrigated', name: 'Орошаемая', areaHa: 50)],
          crops: const [],
          breedProducts: const [],
          productionPlan: const {'milk': 10},
          normativesVersion: 'test-1.0',
        ),
        status: RecordStatus.failed,
        normativesVersion: 'test-1.0',
      );

      final restored = CalculationRecord.fromJson(queued.toJson());

      expect(restored.status, RecordStatus.failed);
      expect(restored.result, isNull);
      expect(restored.totalHeads, 0);
    });
  });

  group('сохранение расчёта', () {
    test('успешный расчёт сохраняется со статусом done и версиями', () async {
      final store = InMemoryCalculationStore();
      final solver = _ControllableSolver();
      await _controller(solver, store).runCalculation();

      final saved = store.readAll().single;
      expect(saved.status, RecordStatus.done);
      expect(saved.result!.totalCost, 1000);
      expect(saved.normativesVersion, 'test-1.0');
      expect(saved.solverVersion, 'stub-1');
      expect(saved.farmTypeId, isNull); // тип хозяйства в этом тесте не выбирался
    });

    test('неудачный расчёт всё равно сохраняется вместе с введёнными данными',
        () async {
      final store = InMemoryCalculationStore();
      final solver = _ControllableSolver()..failWith = SolverFailureKind.serverError;
      final controller = _controller(solver, store);

      await controller.runCalculation();

      expect(controller.state.phase, CalculationPhase.failed);
      final saved = store.readAll().single;
      expect(saved.status, RecordStatus.failed);
      expect(saved.result, isNull);
      // введённые данные не потеряны
      expect(saved.input.lands.single.areaHa, 120);
      expect(saved.input.productionPlan['milk'], 100);
    });

    test('на каждый расчёт создаётся ровно одна запись', () async {
      final store = InMemoryCalculationStore();
      final controller = _controller(_ControllableSolver(), store);

      await controller.runCalculation();
      await controller.runCalculation();

      expect(store.readAll(), hasLength(2));
    });
  });

  test('открытие сохранённого расчёта восстанавливает ввод и результат', () async {
    final store = InMemoryCalculationStore();
    final solver = _ControllableSolver();
    final controller = _controller(solver, store);
    await controller.runCalculation();

    final saved = store.readAll().single;
    controller.reset();
    expect(controller.state.landAreas, isEmpty);

    controller.loadRecord(saved);

    expect(controller.state.landAreas['irrigated'], 120);
    expect(controller.state.productionPlan['milk'], 100);
    expect(controller.state.selectedBreedIds, {'alatau'});
    expect(controller.state.result!.totalCost, 1000);
    expect(controller.state.phase, CalculationPhase.done);
  });
}
