/// Модель данных задачи (1.1)-(1.6). Имена полей зеркалят
/// app/schemas.py бэкенда — см. раздел 02 плана реализации.
library;

class LandCategory {
  const LandCategory({
    required this.id,
    required this.name,
    required this.areaHa, // s[k]
  });

  final String id;
  final String name;
  final double areaHa;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'area_ha': areaHa,
      };

  factory LandCategory.fromJson(Map<String, dynamic> json) => LandCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        areaHa: (json['area_ha'] as num).toDouble(),
      );
}

class Crop {
  const Crop({
    required this.id,
    required this.name,
    required this.yieldByLand, // a[k][j]
    required this.costByLand, // c[k][j]
    this.purchasePricePerTon, // p[j]
  });

  final String id;
  final String name;
  final Map<String, double> yieldByLand;
  final Map<String, double> costByLand;

  /// Цена тонны этого корма на рынке — p[j] из (1.1).
  ///
  /// null означает, что корм не купить: пастбищную траву нельзя
  /// привезти с базара, её либо даёт своё пастбище, либо не даёт
  /// никто. Для таких культур переменная закупки z[j] не создаётся.
  final double? purchasePricePerTon;

  /// Корм можно докупить, если у него есть рыночная цена.
  bool get isPurchasable => purchasePricePerTon != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'yield_by_land': yieldByLand,
        'cost_by_land': costByLand,
        if (purchasePricePerTon != null)
          'purchase_price_per_ton': purchasePricePerTon,
      };

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json['id'] as String,
        name: json['name'] as String,
        yieldByLand: _doubleMap(json['yield_by_land']),
        costByLand: _doubleMap(json['cost_by_land']),
        purchasePricePerTon: (json['purchase_price_per_ton'] as num?)?.toDouble(),
      );
}

Map<String, double> _doubleMap(Object? raw) =>
    ((raw as Map?) ?? const {}).map((k, v) => MapEntry(k as String, (v as num).toDouble()));

/// Пара (порода l, продукция h): модель допускает, что одна порода
/// даёт несколько видов продукции как отдельные решения y[h][l].
class BreedProduct {
  const BreedProduct({
    required this.breedId,
    required this.breedName,
    required this.productId,
    required this.productName,
    required this.yieldPerHead, // v[h][l]
    required this.annualCostPerHead, // d[h][l]
    required this.feedNeed, // q[j][h][l]
  });

  final String breedId;
  final String breedName;
  final String productId;
  final String productName;
  final double yieldPerHead;
  final double annualCostPerHead;
  final Map<String, double> feedNeed;

  Map<String, dynamic> toJson() => {
        'breed_id': breedId,
        'breed_name': breedName,
        'product_id': productId,
        'product_name': productName,
        'yield_per_head': yieldPerHead,
        'annual_cost_per_head': annualCostPerHead,
        'feed_need': feedNeed,
      };

  factory BreedProduct.fromJson(Map<String, dynamic> json) => BreedProduct(
        breedId: json['breed_id'] as String,
        breedName: json['breed_name'] as String,
        productId: json['product_id'] as String,
        productName: json['product_name'] as String,
        yieldPerHead: (json['yield_per_head'] as num).toDouble(),
        annualCostPerHead: (json['annual_cost_per_head'] as num).toDouble(),
        feedNeed: _doubleMap(json['feed_need']),
      );
}

class OptimizationInput {
  const OptimizationInput({
    required this.lands,
    required this.crops,
    required this.breedProducts,
    required this.productionPlan, // b[h]
    required this.normativesVersion,
    this.breedLimits = const {}, // n[l]
  });

  final List<LandCategory> lands;
  final List<Crop> crops;
  final List<BreedProduct> breedProducts;
  final Map<String, double> productionPlan;
  final String normativesVersion;

  /// Предел поголовья по породе — n[l] из (1.7), id породы → голов.
  ///
  /// Порода, которой в карте нет, ничем не ограничена. Ограничение
  /// нужно не математике, а хозяйству: скотомест, доступного
  /// племенного молодняка и рабочих рук всегда конечное число,
  /// а без верхней границы модель охотно ставит всё стадо на одну
  /// породу, потому что задача линейная и оптимум у неё угловой.
  final Map<String, double> breedLimits;

  /// Порядок элементов сортируется по id — решатель индексирует
  /// переменные в том же порядке, и рассинхронизация индексов между
  /// клиентом и сервером даёт правдоподобные, но неверные числа.
  Map<String, dynamic> toJson() => {
        'lands': (lands.toList()..sort((a, b) => a.id.compareTo(b.id)))
            .map((e) => e.toJson())
            .toList(),
        'crops': (crops.toList()..sort((a, b) => a.id.compareTo(b.id)))
            .map((e) => e.toJson())
            .toList(),
        'breed_products': (breedProducts.toList()
              ..sort((a, b) {
                final byBreed = a.breedId.compareTo(b.breedId);
                return byBreed != 0 ? byBreed : a.productId.compareTo(b.productId);
              }))
            .map((e) => e.toJson())
            .toList(),
        'production_plan': productionPlan,
        if (breedLimits.isNotEmpty) 'breed_limits': breedLimits,
        'normatives_version': normativesVersion,
      };

  factory OptimizationInput.fromJson(Map<String, dynamic> json) => OptimizationInput(
        lands: (json['lands'] as List)
            .map((e) => LandCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        crops: (json['crops'] as List)
            .map((e) => Crop.fromJson(e as Map<String, dynamic>))
            .toList(),
        breedProducts: (json['breed_products'] as List)
            .map((e) => BreedProduct.fromJson(e as Map<String, dynamic>))
            .toList(),
        productionPlan: _doubleMap(json['production_plan']),
        breedLimits: _doubleMap(json['breed_limits']),
        normativesVersion: json['normatives_version'] as String,
      );
}

class CropAreaAllocation {
  const CropAreaAllocation({
    required this.landId,
    required this.cropId,
    required this.areaHa,
  });

  final String landId;
  final String cropId;
  final double areaHa;

  factory CropAreaAllocation.fromJson(Map<String, dynamic> json) => CropAreaAllocation(
        landId: json['land_id'] as String,
        cropId: json['crop_id'] as String,
        areaHa: (json['area_ha'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'land_id': landId,
        'crop_id': cropId,
        'area_ha': areaHa,
      };
}

class LivestockAllocation {
  const LivestockAllocation({
    required this.breedId,
    required this.productId,
    required this.heads,
  });

  final String breedId;
  final String productId;
  final int heads;

  factory LivestockAllocation.fromJson(Map<String, dynamic> json) => LivestockAllocation(
        breedId: json['breed_id'] as String,
        productId: json['product_id'] as String,
        heads: json['heads'] as int,
      );

  Map<String, dynamic> toJson() => {
        'breed_id': breedId,
        'product_id': productId,
        'heads': heads,
      };
}

/// Сколько корма пришлось докупить — переменная z[j] из (1.1) и (1.3).
///
/// Хозяйству это отдельная строка расходов и отдельное решение:
/// «купить сено» и «посеять люцерну» — не одно и то же, даже если
/// в целевой функции они складываются в один сом.
class FeedPurchase {
  const FeedPurchase({
    required this.cropId,
    required this.tons,
    required this.cost,
  });

  final String cropId;
  final double tons;

  /// Стоимость закупки: p[j] · z[j].
  final double cost;

  factory FeedPurchase.fromJson(Map<String, dynamic> json) => FeedPurchase(
        cropId: json['crop_id'] as String,
        tons: (json['tons'] as num).toDouble(),
        cost: (json['cost'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'crop_id': cropId,
        'tons': tons,
        'cost': cost,
      };
}

enum SolveStatus { optimal, infeasible }

class OptimizationResult {
  const OptimizationResult({
    required this.status,
    this.totalCost,
    this.cropArea = const [],
    this.livestock = const [],
    this.feedPurchase = const [],
    this.landHaMissing,
    required this.solverVersion,
  });

  final SolveStatus status;
  final double? totalCost;
  final List<CropAreaAllocation> cropArea;
  final List<LivestockAllocation> livestock;

  /// Корма, которые дешевле купить, чем вырастить, — или которые
  /// вырастить негде. Пустой список означает, что хозяйство
  /// обеспечивает себя кормами полностью.
  final List<FeedPurchase> feedPurchase;

  /// Общая стоимость закупленных кормов — третье слагаемое (1.1).
  double get purchaseCost =>
      feedPurchase.fold(0, (sum, p) => sum + p.cost);

  /// Заполнено только при [SolveStatus.infeasible] — сколько гектаров
  /// не хватает, чтобы вырастить корм под заданный план.
  final double? landHaMissing;
  final String solverVersion;

  factory OptimizationResult.fromJson(Map<String, dynamic> json) {
    final shortage = json['shortage'] as Map<String, dynamic>?;
    return OptimizationResult(
      status: json['status'] == 'optimal' ? SolveStatus.optimal : SolveStatus.infeasible,
      totalCost: (json['total_cost'] as num?)?.toDouble(),
      cropArea: ((json['crop_area'] as List?) ?? const [])
          .map((e) => CropAreaAllocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      livestock: ((json['livestock'] as List?) ?? const [])
          .map((e) => LivestockAllocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      feedPurchase: ((json['feed_purchase'] as List?) ?? const [])
          .map((e) => FeedPurchase.fromJson(e as Map<String, dynamic>))
          .toList(),
      landHaMissing: (shortage?['land_ha_missing'] as num?)?.toDouble(),
      solverVersion: json['solver_version'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status == SolveStatus.optimal ? 'optimal' : 'infeasible',
        'total_cost': totalCost,
        'crop_area': cropArea.map((e) => e.toJson()).toList(),
        'livestock': livestock.map((e) => e.toJson()).toList(),
        if (feedPurchase.isNotEmpty)
          'feed_purchase': feedPurchase.map((e) => e.toJson()).toList(),
        if (landHaMissing != null) 'shortage': {'land_ha_missing': landHaMissing},
        'solver_version': solverVersion,
      };
}
