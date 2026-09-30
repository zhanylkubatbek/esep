import '../../../../data/models/farm_model.dart';
import '../../../../data/remote/solver_api.dart';
import '../../domain/farm_type.dart';

/// Иммутабельное состояние мастера расчёта.
///
/// Коллекции внутри никогда не мутируются: каждое изменение — новый
/// экземпляр через [copyWith], чтобы BlocBuilder всегда видел новое
/// состояние.
class CalculatorState {
  const CalculatorState({
    this.farmType,
    this.landAreas = const {},
    this.productionPlan = const {},
    this.selectedBreedIds = const {},
    this.breedLimits = const {},
    this.phase = CalculationPhase.input,
    this.result,
    this.failure,
    this.currentRecordId,
  });

  /// Шаг 1: тип хозяйства.
  final FarmType? farmType;

  /// Шаг 2: угодья, га по id категории (нет ключа = нет такого угодья).
  final Map<String, double> landAreas;

  /// Шаг 3: план производства, т/год по id продукции.
  final Map<String, double> productionPlan;

  /// Шаг 4: выбранные породы (id породы).
  final Set<String> selectedBreedIds;

  /// Шаг 4, необязательно: сколько голов породы хозяйство может
  /// содержать — n[l] из (1.7). Порода без ключа не ограничена.
  final Map<String, double> breedLimits;

  final CalculationPhase phase;
  final OptimizationResult? result;
  final SolverException? failure;

  /// id записи текущего расчёта в хранилище — по нему экран результата
  /// связывается с сохранённой историей.
  final String? currentRecordId;

  double get totalLandHa => landAreas.values.fold(0, (sum, v) => sum + v);

  bool get hasLand => totalLandHa > 0;

  bool get hasPlan => productionPlan.values.any((v) => v > 0);

  bool get hasBreeds => selectedBreedIds.isNotEmpty;

  /// null-поля затираются только через явные флаги: у copyWith нет
  /// способа отличить «не передали» от «передали null».
  CalculatorState copyWith({
    FarmType? farmType,
    Map<String, double>? landAreas,
    Map<String, double>? productionPlan,
    Set<String>? selectedBreedIds,
    Map<String, double>? breedLimits,
    CalculationPhase? phase,
    OptimizationResult? result,
    SolverException? failure,
    String? currentRecordId,
    bool clearResult = false,
    bool clearFailure = false,
  }) =>
      CalculatorState(
        farmType: farmType ?? this.farmType,
        landAreas: landAreas ?? this.landAreas,
        productionPlan: productionPlan ?? this.productionPlan,
        selectedBreedIds: selectedBreedIds ?? this.selectedBreedIds,
        breedLimits: breedLimits ?? this.breedLimits,
        phase: phase ?? this.phase,
        result: clearResult ? null : (result ?? this.result),
        failure: clearFailure ? null : (failure ?? this.failure),
        currentRecordId: currentRecordId ?? this.currentRecordId,
      );
}
