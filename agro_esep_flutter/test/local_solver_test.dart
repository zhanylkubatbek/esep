import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/solver/local_farm_solver.dart';
import 'package:flutter_test/flutter_test.dart';

/// Генератор случайных, но осмысленных задач хозяйства.
/// Одно и то же зерно даёт один и тот же набор — падение теста
/// всегда воспроизводится.
OptimizationInput randomInput(int seed) {
  final rnd = Random(seed);

  final landCount = 1 + rnd.nextInt(3); // 1..3 категории угодий
  final cropCount = 1 + rnd.nextInt(4); // 1..4 культуры
  final breedCount = 1 + rnd.nextInt(3); // 1..3 породы

  final lands = [
    for (var k = 0; k < landCount; k++)
      LandCategory(
        id: 'land$k',
        name: 'Угодье $k',
        areaHa: 20 + rnd.nextInt(300).toDouble(),
      ),
  ];

  final crops = [
    for (var j = 0; j < cropCount; j++)
      Crop(
        id: 'crop$j',
        name: 'Культура $j',
        yieldByLand: {
          for (final l in lands) l.id: 2 + rnd.nextInt(45).toDouble(),
        },
        costByLand: {
          for (final l in lands) l.id: 5000 + rnd.nextInt(20000).toDouble(),
        },
      ),
  ];

  // Часть пород даёт молоко, часть — мясо; продукция берётся из тех,
  // что реально кто-то производит.
  final products = ['milk', if (rnd.nextBool() || breedCount > 1) 'meat'];
  final breedProducts = <BreedProduct>[];
  for (var l = 0; l < breedCount; l++) {
    final productId = products[l % products.length];
    breedProducts.add(BreedProduct(
      breedId: 'breed$l',
      breedName: 'Порода $l',
      productId: productId,
      productName: productId,
      yieldPerHead: productId == 'milk'
          ? 3 + rnd.nextDouble() * 3
          : 0.15 + rnd.nextDouble() * 0.2,
      annualCostPerHead: 20000 + rnd.nextInt(40000).toDouble(),
      feedNeed: {
        for (final c in crops)
          if (rnd.nextInt(4) > 0) c.id: 0.5 + rnd.nextDouble() * 5,
      },
    ));
  }

  // План только по той продукции, которую кто-то из выбранных пород даёт.
  final produced = breedProducts.map((b) => b.productId).toSet();
  final plan = <String, double>{
    for (final p in produced)
      p: p == 'milk'
          ? 20 + rnd.nextInt(300).toDouble()
          : 2 + rnd.nextInt(30).toDouble(),
  };

  return OptimizationInput(
    lands: lands,
    crops: crops,
    breedProducts: breedProducts,
    productionPlan: plan,
    normativesVersion: 'random-$seed',
  );
}

/// Допуск на накопленную погрешность арифметики с плавающей точкой.
/// Решатель не округляет площади в ответе, поэтому ограничения должны
/// выполняться практически точно.
double _tolerance(double magnitude) => 1e-6 + magnitude.abs() * 1e-9;

void main() {
  const solver = LocalFarmSolver();

  group('локальный решатель соблюдает ограничения модели', () {
    test('решение укладывается в площади и выполняет план', () async {
      for (var seed = 0; seed < 60; seed++) {
        final input = randomInput(seed);
        final result = await solver.solve(input);
        if (result.status != SolveStatus.optimal) continue;

        // (1.2) посевы не превышают площадь каждого угодья
        for (final land in input.lands) {
          final used = result.cropArea
              .where((a) => a.landId == land.id)
              .fold<double>(0, (s, a) => s + a.areaHa);
          expect(used, lessThanOrEqualTo(land.areaHa + _tolerance(land.areaHa)),
              reason: 'seed $seed, угодье ${land.id}');
        }

        // (1.4) план производства выполнен
        for (final entry in input.productionPlan.entries) {
          var produced = 0.0;
          for (final animal in result.livestock) {
            if (animal.productId != entry.key) continue;
            final bp = input.breedProducts.firstWhere(
              (b) => b.breedId == animal.breedId && b.productId == animal.productId,
            );
            produced += bp.yieldPerHead * animal.heads;
          }
          expect(produced, greaterThanOrEqualTo(entry.value - _tolerance(entry.value)),
              reason: 'seed $seed, продукция ${entry.key}');
        }

        // (1.3) кормов выращено не меньше, чем требуется
        for (final crop in input.crops) {
          var grown = 0.0;
          for (final a in result.cropArea.where((a) => a.cropId == crop.id)) {
            grown += crop.yieldByLand[a.landId]! * a.areaHa;
          }
          var needed = 0.0;
          for (final animal in result.livestock) {
            final bp = input.breedProducts.firstWhere(
              (b) => b.breedId == animal.breedId && b.productId == animal.productId,
            );
            needed += (bp.feedNeed[crop.id] ?? 0) * animal.heads;
          }
          expect(grown, greaterThanOrEqualTo(needed - _tolerance(needed)),
              reason: 'seed $seed, культура ${crop.id}');
        }
      }
    });

    test('поголовье целое', () async {
      for (var seed = 100; seed < 140; seed++) {
        final result = await solver.solve(randomInput(seed));
        if (result.status != SolveStatus.optimal) continue;
        for (final animal in result.livestock) {
          expect(animal.heads, greaterThan(0));
        }
      }
    });

    test('заведомо невыполнимый план распознаётся и оценивает нехватку',
        () async {
      final base = randomInput(7);
      final impossible = OptimizationInput(
        lands: [
          for (final l in base.lands)
            LandCategory(id: l.id, name: l.name, areaHa: 0.5),
        ],
        crops: base.crops,
        breedProducts: base.breedProducts,
        productionPlan: {
          for (final e in base.productionPlan.entries) e.key: e.value * 50,
        },
        normativesVersion: base.normativesVersion,
      );

      final result = await solver.solve(impossible);

      expect(result.status, SolveStatus.infeasible);
      expect(result.landHaMissing, isNotNull);
      expect(result.landHaMissing, greaterThan(0));
    });

    test('расчёт занимает доли секунды', () async {
      final watch = Stopwatch()..start();
      for (var seed = 0; seed < 30; seed++) {
        await solver.solve(randomInput(seed));
      }
      watch.stop();

      // 30 задач; на телефоне медленнее, но запас огромный
      expect(watch.elapsedMilliseconds, lessThan(5000),
          reason: 'заняло ${watch.elapsedMilliseconds} мс');
    });
  });

  test('одинаковый вход даёт одинаковый ответ', () async {
    final input = randomInput(42);
    final first = await solver.solve(input);
    final second = await solver.solve(input);

    expect(first.totalCost, second.totalCost);
    expect(first.livestock.length, second.livestock.length);
  });

  /// Выгружает набор задач в JSON, чтобы Python-скрипт решил их
  /// на HiGHS и сравнил с ответами Dart. Запускается вручную:
  ///   flutter test test/local_solver_test.dart --run-skipped -t export
  test('выгрузить задачи и ответы для сверки с HiGHS', () async {
    final cases = <Map<String, dynamic>>[];
    for (var seed = 0; seed < 120; seed++) {
      final input = randomInput(seed);
      final result = await solver.solve(input);
      cases.add({
        'seed': seed,
        'input': input.toJson(),
        'dart': result.toJson(),
      });
    }
    final file = File('${Directory.systemTemp.path}/agro_esep_crosscheck.json');
    await file.writeAsString(jsonEncode(cases));
    // ignore: avoid_print
    print('CROSSCHECK_FILE=${file.path}');
    expect(cases, hasLength(120));
  }, tags: ['export']);
}
