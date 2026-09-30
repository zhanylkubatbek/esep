import 'package:agro_esep/solver/simplex.dart';
import 'package:flutter_test/flutter_test.dart';

const _tol = 1e-6;

void main() {
  group('простые задачи с известным ответом', () {
    test('минимум в нуле, когда все затраты положительны', () {
      final r = Simplex.solve(LpProblem(
        objective: [1, 2],
        constraints: [
          [1, 1],
        ],
        rhs: [10],
      ));

      expect(r.status, LpStatus.optimal);
      expect(r.objective, closeTo(0, _tol));
    });

    test('ограничение «не меньше» заставляет уйти из нуля', () {
      // min x  при  x ≥ 5  →  строка −x ≤ −5
      final r = Simplex.solve(LpProblem(
        objective: [1],
        constraints: [
          [-1],
        ],
        rhs: [-5],
      ));

      expect(r.status, LpStatus.optimal);
      expect(r.x.single, closeTo(5, _tol));
      expect(r.objective, closeTo(5, _tol));
    });

    test('выбирается более дешёвый способ выполнить требование', () {
      // min 3a + 2b  при  a + b ≥ 10  → выгоднее взять b
      final r = Simplex.solve(LpProblem(
        objective: [3, 2],
        constraints: [
          [-1, -1],
        ],
        rhs: [-10],
      ));

      expect(r.status, LpStatus.optimal);
      expect(r.objective, closeTo(20, _tol));
      expect(r.x[0], closeTo(0, _tol));
      expect(r.x[1], closeTo(10, _tol));
    });

    test('дешёвый ресурс ограничен — добираем дорогим', () {
      // min 3a + 2b,  a + b ≥ 10,  b ≤ 4  →  b=4, a=6, цена 26
      final r = Simplex.solve(LpProblem(
        objective: [3, 2],
        constraints: [
          [-1, -1],
          [0, 1],
        ],
        rhs: [-10, 4],
      ));

      expect(r.status, LpStatus.optimal);
      expect(r.x[0], closeTo(6, _tol));
      expect(r.x[1], closeTo(4, _tol));
      expect(r.objective, closeTo(26, _tol));
    });

    test('классическая задача на смешивание', () {
      // min 2x + 3y,  x + y ≥ 4,  x + 3y ≥ 6,  x ≤ 10, y ≤ 10
      final r = Simplex.solve(LpProblem(
        objective: [2, 3],
        constraints: [
          [-1, -1],
          [-1, -3],
          [1, 0],
          [0, 1],
        ],
        rhs: [-4, -6, 10, 10],
      ));

      expect(r.status, LpStatus.optimal);
      // оптимум в вершине x=3, y=1 → 2·3 + 3·1 = 9
      expect(r.objective, closeTo(9, _tol));
      expect(r.x[0], closeTo(3, _tol));
      expect(r.x[1], closeTo(1, _tol));
    });
  });

  group('особые случаи', () {
    test('противоречивые требования — задача неразрешима', () {
      // x ≥ 10 и одновременно x ≤ 3
      final r = Simplex.solve(LpProblem(
        objective: [1],
        constraints: [
          [-1],
          [1],
        ],
        rhs: [-10, 3],
      ));

      expect(r.status, LpStatus.infeasible);
    });

    test('неограниченная задача распознаётся', () {
      // min −x  без верхней границы на x
      final r = Simplex.solve(LpProblem(
        objective: [-1],
        constraints: [
          [0],
        ],
        rhs: [5],
      ));

      expect(r.status, LpStatus.unbounded);
    });

    test('задача без ограничений', () {
      final r = Simplex.solve(LpProblem(
        objective: [1, 2],
        constraints: const [],
        rhs: const [],
      ));

      expect(r.status, LpStatus.optimal);
      expect(r.objective, closeTo(0, _tol));
    });

    test('вырожденная задача не зацикливается', () {
      // несколько ограничений проходят через одну вершину
      final r = Simplex.solve(LpProblem(
        objective: [1, 1, 1],
        constraints: [
          [-1, -1, 0],
          [-1, 0, -1],
          [0, -1, -1],
          [1, 1, 1],
        ],
        rhs: [-2, -2, -2, 100],
      ));

      expect(r.status, LpStatus.optimal);
      // симметричная задача: по 1 на каждую переменную
      expect(r.objective, closeTo(3, _tol));
    });

    test('решение неотрицательно во всех переменных', () {
      final r = Simplex.solve(LpProblem(
        objective: [5, 1, 7],
        constraints: [
          [-2, -1, -3],
          [1, 1, 1],
        ],
        rhs: [-12, 20],
      ));

      expect(r.status, LpStatus.optimal);
      for (final v in r.x) {
        expect(v, greaterThanOrEqualTo(-_tol));
      }
    });
  });

  group('масштаб как в реальной задаче хозяйства', () {
    test('десятки переменных решаются', () {
      // 4 угодья × 5 культур = 20 переменных, ограничения по площади
      // и суммарная потребность в корме
      const lands = 4;
      const crops = 5;
      const n = lands * crops;

      final objective = <double>[];
      for (var k = 0; k < lands; k++) {
        for (var j = 0; j < crops; j++) {
          objective.add(10000 + 1000.0 * k + 500.0 * j);
        }
      }

      final constraints = <List<double>>[];
      final rhs = <double>[];

      // площадь каждого угодья
      for (var k = 0; k < lands; k++) {
        final row = List<double>.filled(n, 0);
        for (var j = 0; j < crops; j++) {
          row[k * crops + j] = 1;
        }
        constraints.add(row);
        rhs.add(50);
      }

      // суммарный сбор не меньше требуемого
      final feed = List<double>.filled(n, 0);
      for (var k = 0; k < lands; k++) {
        for (var j = 0; j < crops; j++) {
          feed[k * crops + j] = -(5.0 + k + j);
        }
      }
      constraints.add(feed);
      rhs.add(-300);

      final r = Simplex.solve(LpProblem(
        objective: objective,
        constraints: constraints,
        rhs: rhs,
      ));

      expect(r.status, LpStatus.optimal);
      expect(r.objective, greaterThan(0));

      // проверяем, что ограничения действительно соблюдены
      for (var k = 0; k < lands; k++) {
        var used = 0.0;
        for (var j = 0; j < crops; j++) {
          used += r.x[k * crops + j];
        }
        expect(used, lessThanOrEqualTo(50 + _tol));
      }
      var collected = 0.0;
      for (var i = 0; i < n; i++) {
        collected += -feed[i] * r.x[i];
      }
      expect(collected, greaterThanOrEqualTo(300 - 1e-4));
    });
  });
}
