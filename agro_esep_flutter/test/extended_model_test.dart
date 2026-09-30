import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/solver/local_farm_solver.dart';
import 'package:flutter_test/flutter_test.dart';

/// Расширения модели под условия Кыргызстана: пастбища как источник
/// корма, закупка кормов (1.3) и предел поголовья по породе (1.7).
///
/// Нормативы задаются прямо здесь, а не читаются из assets: тест
/// проверяет поведение модели, и он не должен падать, когда институт
/// заменит демонстрационную базу на настоящую.
const _pastureCost = 1500.0;
const _pastureYield = 3.0;

OptimizationInput _input({
  required Map<String, double> lands,
  required Map<String, double> plan,
  Map<String, double> breedLimits = const {},
  double? pastureGrassPrice = 3500,
}) {
  return OptimizationInput(
    lands: [
      for (final e in lands.entries)
        LandCategory(id: e.key, name: e.key, areaHa: e.value),
    ],
    crops: [
      const Crop(
        id: 'barley',
        name: 'Ячмень',
        yieldByLand: {'irrigated': 4.0},
        costByLand: {'irrigated': 40000},
        purchasePricePerTon: 22000,
      ),
      Crop(
        id: 'pasture_grass',
        name: 'Пастбищный корм',
        yieldByLand: const {'pasture': _pastureYield},
        costByLand: const {'pasture': _pastureCost},
        purchasePricePerTon: pastureGrassPrice,
      ),
    ],
    breedProducts: const [
      BreedProduct(
        breedId: 'grazing',
        breedName: 'Пастбищная',
        productId: 'milk',
        productName: 'Молоко',
        yieldPerHead: 4.0,
        annualCostPerHead: 30000,
        // Пастбищной породе нужно много подножного корма и мало зерна.
        feedNeed: {'pasture_grass': 9.0, 'barley': 0.5},
      ),
      BreedProduct(
        breedId: 'stall',
        breedName: 'Стойловая',
        productId: 'milk',
        productName: 'Молоко',
        yieldPerHead: 4.0,
        annualCostPerHead: 30000,
        // Стойловой — наоборот: пастбище почти не нужно, зерна много.
        feedNeed: {'pasture_grass': 1.0, 'barley': 2.0},
      ),
    ],
    productionPlan: plan,
    breedLimits: breedLimits,
    normativesVersion: 'test-extended',
  );
}

void main() {
  const solver = LocalFarmSolver();

  group('пастбища участвуют в модели', () {
    test('площадь пастбищ меняет затраты', () async {
      final scarce = await solver.solve(_input(
        lands: {'irrigated': 500, 'pasture': 20},
        plan: {'milk': 200},
      ));
      final plenty = await solver.solve(_input(
        lands: {'irrigated': 500, 'pasture': 2000},
        plan: {'milk': 200},
      ));

      expect(scarce.status, SolveStatus.optimal);
      expect(plenty.status, SolveStatus.optimal);
      // Раньше пастбища вообще не влияли на ответ: ни одна культура
      // на них не росла, и введённая площадь уходила в никуда.
      expect(plenty.totalCost, lessThan(scarce.totalCost!),
          reason: 'пастбище должно удешевлять рацион');
    });

    test('пастбищный корм действительно берётся с пастбища', () async {
      final r = await solver.solve(_input(
        lands: {'irrigated': 500, 'pasture': 2000},
        plan: {'milk': 200},
      ));

      final onPasture = r.cropArea
          .where((a) => a.landId == 'pasture' && a.cropId == 'pasture_grass');
      expect(onPasture, isNotEmpty);
    });

    test('дешёвое пастбище склоняет выбор к пастбищной породе', () async {
      final r = await solver.solve(_input(
        lands: {'irrigated': 500, 'pasture': 5000},
        plan: {'milk': 200},
      ));

      final heads = {for (final l in r.livestock) l.breedId: l.heads};
      expect(heads['grazing'] ?? 0, greaterThan(heads['stall'] ?? 0),
          reason: 'при обилии дешёвого подножного корма выгоднее пастбищная');
    });
  });

  group('закупка кормов (1.3)', () {
    test('хозяйство без своей земли выполняет план на покупных кормах',
        () async {
      final r = await solver.solve(_input(
        lands: {'irrigated': 0.0001},
        plan: {'milk': 100},
      ));

      expect(r.status, SolveStatus.optimal,
          reason: 'раньше это был отказ «решение не найдено»');
      expect(r.feedPurchase, isNotEmpty);
      expect(r.livestock.fold<int>(0, (s, l) => s + l.heads), greaterThan(0));
    });

    test('корм без рыночной цены купить нельзя', () async {
      final r = await solver.solve(_input(
        lands: {'irrigated': 500},
        plan: {'milk': 100},
        pastureGrassPrice: null,
      ));

      // Пастбища нет, подножный корм не продаётся — план недостижим.
      expect(r.status, SolveStatus.infeasible);
    });

    test('своё дешевле покупного: при избытке земли закупки нет', () async {
      final r = await solver.solve(_input(
        lands: {'irrigated': 5000, 'pasture': 5000},
        plan: {'milk': 100},
      ));

      expect(r.status, SolveStatus.optimal);
      expect(r.feedPurchase, isEmpty,
          reason: 'закупка дороже собственного производства');
    });

    test('кормовой баланс с закупкой соблюдается по каждой культуре',
        () async {
      final input = _input(
        lands: {'irrigated': 30, 'pasture': 40},
        plan: {'milk': 150},
      );
      final r = await solver.solve(input);
      expect(r.status, SolveStatus.optimal);

      final produced = <String, double>{};
      for (final a in r.cropArea) {
        final crop = input.crops.firstWhere((c) => c.id == a.cropId);
        produced.update(
          a.cropId,
          (v) => v + crop.yieldByLand[a.landId]! * a.areaHa,
          ifAbsent: () => crop.yieldByLand[a.landId]! * a.areaHa,
        );
      }
      for (final p in r.feedPurchase) {
        produced.update(p.cropId, (v) => v + p.tons, ifAbsent: () => p.tons);
      }

      final needed = <String, double>{};
      for (final animal in r.livestock) {
        final bp = input.breedProducts.firstWhere(
          (b) => b.breedId == animal.breedId && b.productId == animal.productId,
        );
        bp.feedNeed.forEach((cropId, perHead) {
          needed.update(cropId, (v) => v + perHead * animal.heads,
              ifAbsent: () => perHead * animal.heads);
        });
      }

      for (final entry in needed.entries) {
        expect((produced[entry.key] ?? 0) + 1e-6,
            greaterThanOrEqualTo(entry.value),
            reason: 'корма ${entry.key} должно хватать');
      }
    });

    test('итог равен сумме трёх слагаемых (1.1)', () async {
      final input = _input(
        lands: {'irrigated': 20, 'pasture': 30},
        plan: {'milk': 120},
      );
      final r = await solver.solve(input);
      expect(r.status, SolveStatus.optimal);

      var expected = 0.0;
      for (final a in r.cropArea) {
        final crop = input.crops.firstWhere((c) => c.id == a.cropId);
        expected += crop.costByLand[a.landId]! * a.areaHa;
      }
      for (final animal in r.livestock) {
        final bp = input.breedProducts.firstWhere(
          (b) => b.breedId == animal.breedId && b.productId == animal.productId,
        );
        expected += bp.annualCostPerHead * animal.heads;
      }
      expected += r.purchaseCost;

      expect(r.totalCost!, closeTo(expected, 1.0));
    });
  });

  group('предел поголовья по породе (1.7)', () {
    test('ограничение соблюдается', () async {
      final r = await solver.solve(_input(
        lands: {'irrigated': 5000, 'pasture': 5000},
        plan: {'milk': 200},
        breedLimits: {'grazing': 10},
      ));

      expect(r.status, SolveStatus.optimal);
      final grazing = r.livestock
          .where((l) => l.breedId == 'grazing')
          .fold<int>(0, (s, l) => s + l.heads);
      expect(grazing, lessThanOrEqualTo(10));
    });

    test('ограничение заставляет подключить вторую породу', () async {
      final free = await solver.solve(_input(
        lands: {'irrigated': 5000, 'pasture': 5000},
        plan: {'milk': 200},
      ));
      final capped = await solver.solve(_input(
        lands: {'irrigated': 5000, 'pasture': 5000},
        plan: {'milk': 200},
        breedLimits: {'grazing': 10},
      ));

      expect(free.livestock.length, 1, reason: 'без границы оптимум угловой');
      expect(capped.livestock.length, 2);
      // Ограничение сужает множество допустимых планов, значит
      // затраты могут только вырасти.
      expect(capped.totalCost!, greaterThanOrEqualTo(free.totalCost!));
    });

    test('предел для невыбранной породы ничего не ломает', () async {
      final r = await solver.solve(_input(
        lands: {'irrigated': 5000, 'pasture': 5000},
        plan: {'milk': 200},
        breedLimits: {'never-heard-of-it': 5},
      ));

      expect(r.status, SolveStatus.optimal);
    });
  });
}
