import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/features/calculator/presentation/result/cost_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_normatives.dart';

void main() {
  final normatives = buildTestNormatives();

  // Люцерна на орошаемой: 15 000 сом/га. Алатауская молочная: 45 000 сом/гол.
  const result = OptimizationResult(
    status: SolveStatus.optimal,
    totalCost: 15000 * 10 + 45000 * 24,
    cropArea: [CropAreaAllocation(landId: 'irrigated', cropId: 'alfalfa', areaHa: 10)],
    livestock: [LivestockAllocation(breedId: 'alatau', productId: 'milk', heads: 24)],
    solverVersion: 'test',
  );

  test('слагаемые считаются по тем же нормативам, что ушли в запрос', () {
    final breakdown = CostBreakdown.of(result, normatives);

    expect(breakdown.cropCost, 150000);
    expect(breakdown.livestockCost, 1080000);
    expect(breakdown.total, 1230000);
  });

  test('разбивка сходится с итогом решателя', () {
    final breakdown = CostBreakdown.of(result, normatives);
    expect(breakdown.matches(result.totalCost), isTrue);
  });

  test('доли считаются и дают в сумме 100 %', () {
    final breakdown = CostBreakdown.of(result, normatives);

    expect(breakdown.cropPercent, 12);
    expect(breakdown.livestockPercent, 88);
    expect(breakdown.cropPercent + breakdown.livestockPercent, 100);
  });

  test('расхождение с итогом решателя обнаруживается', () {
    final breakdown = CostBreakdown.of(result, normatives);

    // если сервер посчитал по другим нормативам — показывать доли нельзя
    expect(breakdown.matches(999999), isFalse);
    expect(breakdown.matches(null), isFalse);
  });

  test('неизвестная культура не роняет расчёт, а исключается', () {
    const withUnknown = OptimizationResult(
      status: SolveStatus.optimal,
      totalCost: 150000,
      cropArea: [
        CropAreaAllocation(landId: 'irrigated', cropId: 'alfalfa', areaHa: 10),
        CropAreaAllocation(landId: 'irrigated', cropId: 'unknown_crop', areaHa: 5),
      ],
      livestock: [],
      solverVersion: 'test',
    );

    final breakdown = CostBreakdown.of(withUnknown, normatives);
    expect(breakdown.cropCost, 150000);
    // итог не сойдётся -> экран скроет диаграмму вместо показа неверных долей
    expect(breakdown.matches(200000), isFalse);
  });

  test('пустой результат не делит на ноль', () {
    const empty = OptimizationResult(
      status: SolveStatus.optimal,
      totalCost: 0,
      solverVersion: 'test',
    );

    final breakdown = CostBreakdown.of(empty, normatives);
    expect(breakdown.total, 0);
    expect(breakdown.cropShare, 0);
    expect(breakdown.livestockShare, 0);
  });
}
