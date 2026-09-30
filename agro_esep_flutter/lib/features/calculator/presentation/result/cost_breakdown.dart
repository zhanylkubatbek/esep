import '../../../../data/models/farm_model.dart';
import '../../../../data/normatives/normatives.dart';

/// Разбивка суммарных затрат L(x,y,z) на три слагаемых целевой
/// функции (1.1): затраты на посевы Σ c[k][j]·x[k][j], на содержание
/// животных Σ d[h][l]·y[h][l] и на закупку кормов Σ p[j]·z[j].
///
/// Решатель возвращает только итог, поэтому слагаемые считаются здесь
/// по тем же нормативам, что уходили в запрос.
class CostBreakdown {
  const CostBreakdown({
    required this.cropCost,
    required this.livestockCost,
    required this.purchaseCost,
  });

  final double cropCost;
  final double livestockCost;

  /// Третье слагаемое (1.1). Ноль, если хозяйство обходится
  /// своими кормами.
  final double purchaseCost;

  double get total => cropCost + livestockCost + purchaseCost;

  double get cropShare => total == 0 ? 0 : cropCost / total;
  double get livestockShare => total == 0 ? 0 : livestockCost / total;
  double get purchaseShare => total == 0 ? 0 : purchaseCost / total;

  int get cropPercent => (cropShare * 100).round();
  int get purchasePercent => (purchaseShare * 100).round();

  /// Досчитывается до сотни, чтобы подписи на шкале не давали 99 % или
  /// 101 % из-за независимого округления каждой доли.
  int get livestockPercent => 100 - cropPercent - purchasePercent;

  bool get hasPurchase => purchaseCost > 0;

  static CostBreakdown of(OptimizationResult result, Normatives normatives) {
    final cropsById = {for (final c in normatives.crops) c.id: c};
    var crops = 0.0;
    for (final allocation in result.cropArea) {
      final costPerHa = cropsById[allocation.cropId]?.costByLand[allocation.landId];
      if (costPerHa != null) crops += costPerHa * allocation.areaHa;
    }

    var livestock = 0.0;
    for (final animal in result.livestock) {
      for (final bp in normatives.breedProducts) {
        if (bp.breedId == animal.breedId && bp.productId == animal.productId) {
          livestock += bp.annualCostPerHead * animal.heads;
          break;
        }
      }
    }

    return CostBreakdown(
      cropCost: crops,
      livestockCost: livestock,
      purchaseCost: result.purchaseCost,
    );
  }

  /// Сходится ли разбивка с итогом решателя. Расхождение больше
  /// копеечного означает рассогласование нормативов между клиентом
  /// и сервером — такую разбивку показывать нельзя.
  bool matches(double? solverTotal) =>
      solverTotal != null && (total - solverTotal).abs() < 1.0;
}
