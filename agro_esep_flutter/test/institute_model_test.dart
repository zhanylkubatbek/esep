import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/solver/local_farm_solver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'local_solver_test.dart' show randomInput;

/// Сверка с постановкой института (1.1)–(1.6) в чистом виде.
///
/// Расширения под условия КР — закупка кормов z[j] и предел поголовья
/// n[l] — должны быть строго необязательными: на базе без закупочных
/// цен и без заданных пределов приложение обязано решать ровно ту
/// задачу, которая записана в документе института, а не её вариацию.
/// Этот файл — граница между «нашим» и «институтским».
void main() {
  const solver = LocalFarmSolver();

  test('без закупочных цен и пределов задача сводится к (1.1)-(1.6)', () async {
    for (var seed = 0; seed < 40; seed++) {
      final input = randomInput(seed);

      // Постановка института закупки не знает: у культур нет цены.
      expect(input.crops.every((c) => !c.isPurchasable), isTrue);
      expect(input.breedLimits, isEmpty);

      final result = await solver.solve(input);
      if (result.status != SolveStatus.optimal) continue;

      // Переменных z нет — значит и закупки быть не может.
      expect(result.feedPurchase, isEmpty, reason: 'seed $seed');
      expect(result.purchaseCost, 0, reason: 'seed $seed');

      // (1.1) итог равен ровно двум слагаемым института:
      //   L(x,y) = Σ c[k][j]·x[k][j] + Σ c[h][l]·y[h][l]
      var objective = 0.0;
      for (final a in result.cropArea) {
        final crop = input.crops.firstWhere((c) => c.id == a.cropId);
        objective += crop.costByLand[a.landId]! * a.areaHa;
      }
      for (final animal in result.livestock) {
        final bp = input.breedProducts.firstWhere(
          (b) => b.breedId == animal.breedId && b.productId == animal.productId,
        );
        objective += bp.annualCostPerHead * animal.heads;
      }
      expect(result.totalCost!, closeTo(objective, 1.0), reason: 'seed $seed');
    }
  });

  test('(1.6) поголовье — целое неотрицательное', () async {
    for (var seed = 0; seed < 40; seed++) {
      final result = await solver.solve(randomInput(seed));
      if (result.status != SolveStatus.optimal) continue;
      for (final animal in result.livestock) {
        // heads объявлено int, поэтому проверяется не тип, а то, что
        // округление не подменило ответ: восстановленный по нему план
        // обязан оставаться допустимым — это проверяет local_solver_test.
        expect(animal.heads, greaterThan(0), reason: 'seed $seed');
      }
    }
  });

  test('пустая карта пределов не добавляет ограничений в задачу', () async {
    final base = randomInput(11);
    final withEmptyLimits = OptimizationInput(
      lands: base.lands,
      crops: base.crops,
      breedProducts: base.breedProducts,
      productionPlan: base.productionPlan,
      breedLimits: const {},
      normativesVersion: base.normativesVersion,
    );

    final a = await solver.solve(base);
    final b = await solver.solve(withEmptyLimits);

    expect(a.status, b.status);
    expect(a.totalCost, b.totalCost);
  });
}
