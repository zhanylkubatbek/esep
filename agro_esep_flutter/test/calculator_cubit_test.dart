import 'package:agro_esep/data/local/calculation_store.dart';
import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/data/remote/solver_api.dart';
import 'package:agro_esep/features/calculator/domain/farm_type.dart';
import 'package:agro_esep/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_normatives.dart';

class _StubSolver implements FarmSolver {
  OptimizationInput? lastInput;

  @override
  Future<OptimizationResult> solve(OptimizationInput input) async {
    lastInput = input;
    return const OptimizationResult(status: SolveStatus.optimal, solverVersion: 'stub');
  }
}

void main() {
  late CalculatorCubit controller;
  late _StubSolver solver;
  late InMemoryCalculationStore store;

  setUp(() {
    solver = _StubSolver();
    store = InMemoryCalculationStore();
    controller = CalculatorCubit(
      normatives: buildTestNormatives(),
      solver: solver,
      store: store,
    );
  });

  group('сборка запроса', () {
    test('в задачу попадают только заполненные угодья', () {
      controller.setLandArea('irrigated', 120);
      controller.setProductionPlan('milk', 100);
      controller.toggleBreed('alatau');

      final input = controller.buildInput();

      final alfalfa = input.crops.firstWhere((c) => c.id == 'alfalfa');
      expect(input.lands.map((l) => l.id), ['irrigated']);
      // урожайность по незаполненной богаре не должна утечь в запрос
      expect(alfalfa.yieldByLand.keys, ['irrigated']);
      expect(alfalfa.costByLand.keys, ['irrigated']);
    });

    test('культура, которую негде посеять, остаётся в задаче', () {
      controller.setLandArea('irrigated', 120); // пастбищ у хозяйства нет
      controller.setProductionPlan('milk', 100);
      controller.toggleBreed('alatau');

      final input = controller.buildInput();
      final grass = input.crops.firstWhere((c) => c.id == 'pasture_grass');

      // Если выбросить культуру, вместе с ней исчезнет и строка
      // кормового баланса (1.3) — стадо получит этот корм даром.
      expect(grass.yieldByLand, isEmpty);
      expect(grass.purchasePricePerTon, 3500,
          reason: 'цена нужна, чтобы корм можно было докупить');
    });

    test('предел поголовья уходит в задачу только для выбранных пород', () {
      controller.setLandArea('irrigated', 120);
      controller.setProductionPlan('milk', 100);
      controller.toggleBreed('alatau');
      controller.setBreedLimit('alatau', 40);
      controller.setBreedLimit('kyrgyz_meat', 15); // порода не выбрана

      expect(controller.buildInput().breedLimits, {'alatau': 40.0});
    });

    test('снятая порода уносит свой предел', () {
      controller.toggleBreed('alatau');
      controller.setBreedLimit('alatau', 40);
      expect(controller.state.breedLimits, containsPair('alatau', 40.0));

      controller.toggleBreed('alatau');
      expect(controller.state.breedLimits, isEmpty);
    });

    test('пустой предел означает «не ограничиваю», а не ноль голов', () {
      controller.toggleBreed('alatau');
      controller.setBreedLimit('alatau', 40);
      controller.setBreedLimit('alatau', null);

      expect(controller.state.breedLimits, isEmpty);
    });

    test('в задачу попадают только выбранные породы и запланированная продукция', () {
      controller.setLandArea('irrigated', 120);
      controller.setProductionPlan('milk', 100);
      controller.toggleBreed('alatau');
      controller.toggleBreed('kyrgyz_meat'); // мясная порода без плана по мясу

      final input = controller.buildInput();

      expect(input.breedProducts.map((bp) => bp.breedId), ['alatau']);
      expect(input.productionPlan.keys, ['milk']);
    });

    test('элементы запроса отсортированы по id независимо от порядка выбора', () {
      controller.setLandArea('rainfed', 200);
      controller.setLandArea('irrigated', 120);
      controller.setProductionPlan('meat', 5);
      controller.setProductionPlan('milk', 100);
      controller.toggleBreed('kyrgyz_meat');
      controller.toggleBreed('alatau');

      final json = controller.buildInput().toJson();
      final landIds = (json['lands'] as List).map((e) => e['id']).toList();
      final breedIds = (json['breed_products'] as List).map((e) => e['breed_id']).toList();

      expect(landIds, ['irrigated', 'rainfed']);
      expect(breedIds, ['alatau', 'kyrgyz_meat']);
    });

    test('версия нормативов уходит вместе с запросом', () {
      controller.setLandArea('irrigated', 10);
      expect(controller.buildInput().normativesVersion, 'test-1.0');
    });
  });

  group('проверки перед расчётом', () {
    test('нереалистичный план даёт предупреждение', () {
      controller.setLandArea('irrigated', 10);
      controller.setProductionPlan('milk', 3000);

      expect(controller.plausibilityWarnings, hasLength(1));
      expect(controller.plausibilityWarnings.single.productId, 'milk');
    });

    test('правдоподобный план предупреждений не даёт', () {
      controller.setLandArea('irrigated', 320);
      controller.setProductionPlan('milk', 300);

      expect(controller.plausibilityWarnings, isEmpty);
    });

    test('выбранные породы должны покрывать все виды продукции из плана', () {
      controller.setLandArea('irrigated', 120);
      controller.setProductionPlan('milk', 100);
      controller.setProductionPlan('meat', 5);
      controller.toggleBreed('alatau'); // только молочная

      expect(controller.selectedBreedsCoverPlan, isFalse);
      expect(controller.uncoveredProductIds, ['meat']);

      controller.toggleBreed('kyrgyz_meat');
      expect(controller.selectedBreedsCoverPlan, isTrue);
    });
  });

  test('пустое поле удаляет значение, а не записывает ноль', () {
    controller.setLandArea('irrigated', 120);
    expect(controller.state.landAreas, containsPair('irrigated', 120));

    controller.setLandArea('irrigated', null);
    expect(controller.state.landAreas, isEmpty);
    expect(controller.state.hasLand, isFalse);
  });

  test('расчёт проходит фазы solving -> done', () async {
    controller.setLandArea('irrigated', 120);
    controller.setProductionPlan('milk', 100);
    controller.toggleBreed('alatau');

    final future = controller.runCalculation();
    expect(controller.state.phase, CalculationPhase.solving);

    await future;
    expect(controller.state.phase, CalculationPhase.done);
    expect(solver.lastInput, isNotNull);
  });
}
