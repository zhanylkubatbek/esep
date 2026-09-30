import 'package:agro_esep/data/models/calculation_record.dart';
import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/features/history/domain/calculation_diff.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_normatives.dart';

CalculationRecord _record({
  required String id,
  required DateTime at,
  required double cost,
  double alfalfaHa = 10,
  int heads = 20,
  String normativesVersion = 'test-1.0',
}) =>
    CalculationRecord(
      id: id,
      createdAt: at,
      input: const OptimizationInput(
        lands: [LandCategory(id: 'irrigated', name: 'Орошаемая пашня', areaHa: 120)],
        crops: [],
        breedProducts: [],
        productionPlan: {'milk': 100},
        normativesVersion: 'test-1.0',
      ),
      status: RecordStatus.done,
      normativesVersion: normativesVersion,
      result: OptimizationResult(
        status: SolveStatus.optimal,
        totalCost: cost,
        cropArea: [
          CropAreaAllocation(landId: 'irrigated', cropId: 'alfalfa', areaHa: alfalfaHa),
        ],
        livestock: [
          LivestockAllocation(breedId: 'alatau', productId: 'milk', heads: heads),
        ],
        solverVersion: 'test',
      ),
      solverVersion: 'test',
    );

void main() {
  final normatives = buildTestNormatives();

  test('«раньше» определяется по дате, а не по порядку аргументов', () {
    final older = _record(id: 'a', at: DateTime(2026, 8, 1), cost: 1000);
    final newer = _record(id: 'b', at: DateTime(2026, 8, 5), cost: 900);

    final direct = CalculationDiff.of(older, newer, normatives);
    final reversed = CalculationDiff.of(newer, older, normatives);

    expect(direct.before.id, 'a');
    expect(reversed.before.id, 'a');
    expect(direct.costDelta, reversed.costDelta);
  });

  test('экономия считается в сомах и процентах', () {
    final diff = CalculationDiff.of(
      _record(id: 'a', at: DateTime(2026, 8, 1), cost: 1000000),
      _record(id: 'b', at: DateTime(2026, 8, 5), cost: 900000),
      normatives,
    );

    expect(diff.isCheaper, isTrue);
    expect(diff.costDelta, -100000);
    expect(diff.savingsPercent, 10);
  });

  test('подорожание распознаётся как подорожание', () {
    final diff = CalculationDiff.of(
      _record(id: 'a', at: DateTime(2026, 8, 1), cost: 1000000),
      _record(id: 'b', at: DateTime(2026, 8, 5), cost: 1200000),
      normatives,
    );

    expect(diff.isCheaper, isFalse);
    expect(diff.savingsPercent, -20);
  });

  test('изменения посевов и поголовья попадают в разбор', () {
    final diff = CalculationDiff.of(
      _record(id: 'a', at: DateTime(2026, 8, 1), cost: 1000, alfalfaHa: 10, heads: 20),
      _record(id: 'b', at: DateTime(2026, 8, 5), cost: 900, alfalfaHa: 14, heads: 18),
      normatives,
    );

    final crop = diff.crops.single;
    expect(crop.label, 'Люцерна');
    expect(crop.before, 10);
    expect(crop.after, 14);
    expect(crop.delta, 4);

    final animals = diff.livestock.single;
    expect(animals.label, contains('Алатауская'));
    expect(animals.delta, -2);
  });

  test('одинаковые значения помечаются как «без изменений»', () {
    final diff = CalculationDiff.of(
      _record(id: 'a', at: DateTime(2026, 8, 1), cost: 1000, alfalfaHa: 10),
      _record(id: 'b', at: DateTime(2026, 8, 5), cost: 1000, alfalfaHa: 10),
      normatives,
    );

    expect(diff.crops.single.isUnchanged, isTrue);
  });

  test('расчёты на разных нормативах помечаются как несравнимые', () {
    final diff = CalculationDiff.of(
      _record(id: 'a', at: DateTime(2026, 8, 1), cost: 1000, normativesVersion: 'test-1.0'),
      _record(id: 'b', at: DateTime(2026, 8, 5), cost: 700, normativesVersion: 'test-2.0'),
      normatives,
    );

    expect(diff.comparable, isFalse);
    // Версии остаются доступными: текст предупреждения собирает экран.
    expect(diff.before.normativesVersion, 'test-1.0');
    expect(diff.after.normativesVersion, 'test-2.0');
  });

  test('нулевая база не даёт деления на ноль', () {
    final diff = CalculationDiff.of(
      _record(id: 'a', at: DateTime(2026, 8, 1), cost: 0),
      _record(id: 'b', at: DateTime(2026, 8, 5), cost: 500),
      normatives,
    );

    expect(diff.savingsPercent, 0);
  });
}
