@Tags(['live'])
library;

import 'package:agro_esep/data/local/calculation_store.dart';
import 'package:agro_esep/data/models/calculation_record.dart';
import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/data/remote/solver_api.dart';
import 'package:agro_esep/features/calculator/domain/farm_type.dart';
import 'package:agro_esep/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_normatives.dart';

/// Сквозная проверка против настоящего решателя, а не заглушки.
/// Требует запущенного бэкенда:
///   cd agro_esep_python && uvicorn app.main:app
/// Запуск: flutter test test/live_backend_test.dart --tags live
void main() {
  late CalculatorCubit controller;
  late InMemoryCalculationStore store;

  setUp(() {
    store = InMemoryCalculationStore();
    controller = CalculatorCubit(
      normatives: buildTestNormatives(),
      solver: RemoteFarmSolver(baseUrl: 'http://127.0.0.1:8000'),
      store: store,
    );
  });

  test('реальный расчёт возвращает выполнимое решение', () async {
    controller
      ..setLandArea('irrigated', 120)
      ..setLandArea('rainfed', 200)
      ..setProductionPlan('milk', 100)
      ..toggleBreed('alatau');

    await controller.runCalculation();

    expect(controller.state.phase, CalculationPhase.done, reason: '${controller.state.failure}');
    final result = controller.state.result!;
    expect(result.status, SolveStatus.optimal);
    expect(result.totalCost, greaterThan(0));
    expect(result.cropArea, isNotEmpty);
    expect(result.livestock, isNotEmpty);

    // (1.4): поголовье действительно покрывает план по молоку
    final heads = result.livestock.single.heads;
    expect(heads * 4.2, greaterThanOrEqualTo(100));

    // (1.2): посевы помещаются в заявленные угодья
    final irrigatedUsed = result.cropArea
        .where((a) => a.landId == 'irrigated')
        .fold<double>(0, (sum, a) => sum + a.areaHa);
    expect(irrigatedUsed, lessThanOrEqualTo(120.001));
  });

  test('недостижимый план возвращает нехватку земли, а не ошибку', () async {
    controller
      ..setLandArea('irrigated', 2)
      ..setProductionPlan('milk', 500)
      ..toggleBreed('alatau');

    await controller.runCalculation();

    expect(controller.state.phase, CalculationPhase.done);
    expect(controller.state.result!.status, SolveStatus.infeasible);
    expect(controller.state.result!.landHaMissing, greaterThan(0));
  });

  test('реальный расчёт сохраняется и открывается заново из истории', () async {
    controller
      ..setLandArea('irrigated', 120)
      ..setProductionPlan('milk', 100)
      ..toggleBreed('alatau');

    await controller.runCalculation();

    final saved = store.readAll().single;
    expect(saved.status, RecordStatus.done);
    expect(saved.solverVersion, 'scipy-milp-highs');
    expect(saved.normativesVersion, 'test-1.0');

    // запись переживает сериализацию так же, как в Hive
    final restored = CalculationRecord.fromJson(saved.toJson());
    controller.reset();
    controller.loadRecord(restored);

    expect(controller.state.landAreas['irrigated'], 120);
    expect(controller.state.result!.totalCost, saved.result!.totalCost);
    expect(controller.state.result!.livestock.single.heads,
        saved.result!.livestock.single.heads);
  });
}
