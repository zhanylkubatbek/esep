import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/farm_model.dart';

/// Справочник культуры/породы/продукции, поставляемый вместе
/// с приложением. Пользователь эти числа не вводит — он вводит
/// только данные своего хозяйства (~15 значений).
class Normatives {
  const Normatives({
    required this.version,
    required this.isDemo,
    required this.lands,
    required this.crops,
    required this.products,
    required this.breedProducts,
    required this.maxMilkPerHa,
    required this.maxMeatPerHa,
    this.cropNamesKy = const {},
    this.breedNamesKy = const {},
  });

  final String version;

  /// true, пока используется временная демонстрационная база —
  /// приложение обязано честно предупреждать об этом пользователя.
  final bool isDemo;

  final List<NormativeLand> lands;
  final List<Crop> crops;
  final List<NormativeProduct> products;
  final List<BreedProduct> breedProducts;

  /// Кыргызские названия культур и пород, id → название.
  ///
  /// Лежат рядом с записями, а не внутри них: [Crop] и [BreedProduct]
  /// уходят в запрос решателю и в сохранённый расчёт, где название —
  /// лишний вес. Пустая карта означает, что перевода в базе нет.
  final Map<String, String> cropNamesKy;
  final Map<String, String> breedNamesKy;

  /// Названия справочника на языке интерфейса.
  ///
  /// Если кыргызского названия в базе нет, остаётся русское: чужой
  /// язык на экране лучше, чем пустая строка или голый id.
  NormativeNames namesFor(String languageCode) {
    final ky = languageCode == 'ky';
    String pick(String? translated, String original) =>
        ky && translated != null && translated.isNotEmpty ? translated : original;

    return NormativeNames._(
      lands: {for (final l in lands) l.id: pick(l.nameKy, l.name)},
      crops: {for (final c in crops) c.id: pick(cropNamesKy[c.id], c.name)},
      products: {for (final p in products) p.id: pick(p.nameKy, p.name)},
      units: {for (final p in products) p.id: pick(p.unitKy, p.unit)},
      breeds: {
        for (final bp in breedProducts)
          bp.breedId: pick(breedNamesKy[bp.breedId], bp.breedName),
      },
    );
  }

  /// Пороги правдоподобия для проверки ввода (экран 3 макетов).
  final double maxMilkPerHa;
  final double maxMeatPerHa;

  /// Породы, сгруппированные по id — одна порода может давать
  /// несколько видов продукции отдельными переменными y[h][l].
  Map<String, List<BreedProduct>> get breedsById {
    final grouped = <String, List<BreedProduct>>{};
    for (final bp in breedProducts) {
      grouped.putIfAbsent(bp.breedId, () => []).add(bp);
    }
    return grouped;
  }

  double? plausibilityLimitFor(String productId) => switch (productId) {
        'milk' => maxMilkPerHa,
        'meat' => maxMeatPerHa,
        _ => null,
      };

  static Future<Normatives> loadFromAssets() async {
    final raw = await rootBundle.loadString('assets/normatives/normatives.json');
    return Normatives.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory Normatives.fromJson(Map<String, dynamic> json) {
    final plausibility = (json['plausibility'] as Map<String, dynamic>?) ?? const {};
    final cropsJson = (json['crops'] as List).cast<Map<String, dynamic>>();
    final breedsJson = (json['breed_products'] as List).cast<Map<String, dynamic>>();

    return Normatives(
      version: json['version'] as String,
      isDemo: json['is_demo'] as bool? ?? false,
      lands: (json['lands'] as List)
          .map((e) => NormativeLand.fromJson(e as Map<String, dynamic>))
          .toList(),
      crops: cropsJson.map((crop) {
        return Crop(
          id: crop['id'] as String,
          name: crop['name'] as String,
          yieldByLand: _toDoubleMap(crop['yield_by_land']),
          costByLand: _toDoubleMap(crop['cost_by_land']),
          purchasePricePerTon:
              (crop['purchase_price_per_ton'] as num?)?.toDouble(),
        );
      }).toList(),
      products: (json['products'] as List)
          .map((e) => NormativeProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      breedProducts: breedsJson.map((bp) {
        return BreedProduct(
          breedId: bp['breed_id'] as String,
          breedName: bp['breed_name'] as String,
          productId: bp['product_id'] as String,
          productName: bp['product_name'] as String,
          yieldPerHead: (bp['yield_per_head'] as num).toDouble(),
          annualCostPerHead: (bp['annual_cost_per_head'] as num).toDouble(),
          feedNeed: _toDoubleMap(bp['feed_need']),
        );
      }).toList(),
      maxMilkPerHa: (plausibility['max_milk_t_per_ha'] as num?)?.toDouble() ?? double.infinity,
      maxMeatPerHa: (plausibility['max_meat_t_per_ha'] as num?)?.toDouble() ?? double.infinity,
      cropNamesKy: _namesKy(cropsJson, 'id', 'name_ky'),
      breedNamesKy: _namesKy(breedsJson, 'breed_id', 'breed_name_ky'),
    );
  }

  /// Собирает карту «id → перевод», пропуская записи без перевода:
  /// база может быть и одноязычной.
  static Map<String, String> _namesKy(
    List<Map<String, dynamic>> rows,
    String idField,
    String nameField,
  ) =>
      {
        for (final row in rows)
          if (row[nameField] is String && (row[nameField] as String).isNotEmpty)
            row[idField] as String: row[nameField] as String,
      };

  static Map<String, double> _toDoubleMap(Object? raw) =>
      ((raw as Map?) ?? const {}).map((k, v) => MapEntry(k as String, (v as num).toDouble()));
}

class NormativeLand {
  const NormativeLand({required this.id, required this.name, this.nameKy});

  final String id;
  final String name;

  /// null, если в базе нет кыргызского названия.
  final String? nameKy;

  factory NormativeLand.fromJson(Map<String, dynamic> json) => NormativeLand(
        id: json['id'] as String,
        name: json['name'] as String,
        nameKy: json['name_ky'] as String?,
      );
}

class NormativeProduct {
  const NormativeProduct({
    required this.id,
    required this.name,
    required this.unit,
    this.nameKy,
    this.unitKy,
  });

  final String id;
  final String name;
  final String unit;

  /// null, если в базе нет кыргызского названия или единицы.
  final String? nameKy;
  final String? unitKy;

  factory NormativeProduct.fromJson(Map<String, dynamic> json) => NormativeProduct(
        id: json['id'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String,
        nameKy: json['name_ky'] as String?,
        unitKy: json['unit_ky'] as String?,
      );
}

/// Готовые названия справочника на одном языке: экраны берут их по id
/// и не знают, был ли перевод в базе.
class NormativeNames {
  const NormativeNames._({
    required Map<String, String> lands,
    required Map<String, String> crops,
    required Map<String, String> products,
    required Map<String, String> units,
    required Map<String, String> breeds,
  })  : _lands = lands,
        _crops = crops,
        _products = products,
        _units = units,
        _breeds = breeds;

  final Map<String, String> _lands;
  final Map<String, String> _crops;
  final Map<String, String> _products;
  final Map<String, String> _units;
  final Map<String, String> _breeds;

  /// Если id в справочнике нет (расчёт сохранён на другой версии базы),
  /// показываем сам id: так видно, чего не хватает.
  String land(String id) => _lands[id] ?? id;
  String crop(String id) => _crops[id] ?? id;
  String product(String id) => _products[id] ?? id;
  String breed(String id) => _breeds[id] ?? id;

  /// Единица измерения продукции («т/год» / «т/жыл»).
  String unit(String productId) => _units[productId] ?? '';
}
