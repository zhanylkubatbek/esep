import '../data/models/farm_model.dart';
import '../data/remote/solver_api.dart';
import 'branch_and_bound.dart';
import 'simplex.dart';

/// Решатель задачи (1.1)–(1.8) прямо на устройстве.
///
/// Порядок переменных задан явно и совпадает с порядком в Python-версии:
/// сначала все x[k][j] по отсортированным id угодий и культур, затем все
/// y[h][l] по отсортированным id пород и продукции, и только потом —
/// добавленные позже z[j] по отсортированным id закупаемых кормов.
/// Закупка приписана в хвост намеренно: индексы x и y не сдвинулись,
/// и старые контрольные примеры сверяются с новой версией как есть.
class LocalFarmSolver implements FarmSolver {
  const LocalFarmSolver();

  static const version = 'dart-simplex-bnb-2';

  @override
  Future<OptimizationResult> solve(OptimizationInput input) async {
    final model = _FarmModel.build(input);
    if (model.isEmpty) {
      return const OptimizationResult(
        status: SolveStatus.infeasible,
        solverVersion: version,
      );
    }

    final result = BranchAndBound.solve(
      model.problem,
      integerVariables: model.integerVariables,
    );

    if (!result.isOptimal) {
      return OptimizationResult(
        status: SolveStatus.infeasible,
        landHaMissing: model.estimateLandShortage(),
        solverVersion: version,
      );
    }

    return model.toResult(result);
  }
}

/// Раскладка задачи хозяйства в матрицы линейного программирования.
class _FarmModel {
  _FarmModel._({
    required this.input,
    required this.xKeys,
    required this.yKeys,
    required this.zKeys,
    required this.problem,
    required this.integerVariables,
  });

  final OptimizationInput input;

  /// (id угодья, id культуры) для каждой переменной x.
  final List<({String landId, String cropId})> xKeys;

  /// (id породы, id продукции) для каждой переменной y.
  final List<({String breedId, String productId})> yKeys;

  /// id культуры для каждой переменной z — закупки корма.
  final List<String> zKeys;

  final LpProblem problem;
  final Set<int> integerVariables;

  /// Без животных планировать нечего. Отсутствие угодий больше не
  /// делает задачу пустой: хозяйство без своей земли может выполнить
  /// план на покупных кормах, и модель обязана это посчитать,
  /// а не отвечать «решение не найдено».
  bool get isEmpty => yKeys.isEmpty;

  static _FarmModel build(OptimizationInput input, {bool ignoreLandLimits = false}) {
    final landIds = input.lands.map((l) => l.id).toList()..sort();
    final cropsById = {for (final c in input.crops) c.id: c};
    final cropIds = cropsById.keys.toList()..sort();

    // Переменная x создаётся только для тех пар «угодье — культура»,
    // где заданы и урожайность, и затраты: остальные сочетания
    // агрономически не заданы и в задаче не участвуют.
    final xKeys = <({String landId, String cropId})>[];
    for (final landId in landIds) {
      for (final cropId in cropIds) {
        final crop = cropsById[cropId]!;
        if (crop.yieldByLand.containsKey(landId) && crop.costByLand.containsKey(landId)) {
          xKeys.add((landId: landId, cropId: cropId));
        }
      }
    }

    final yKeys = input.breedProducts
        .map((bp) => (breedId: bp.breedId, productId: bp.productId))
        .toList()
      ..sort((a, b) {
        final byBreed = a.breedId.compareTo(b.breedId);
        return byBreed != 0 ? byBreed : a.productId.compareTo(b.productId);
      });

    final bpByKey = {
      for (final bp in input.breedProducts) '${bp.breedId}|${bp.productId}': bp,
    };

    // Переменная z создаётся только для кормов с рыночной ценой.
    // Корм без цены купить негде, и отсутствие столбца честнее,
    // чем столбец с выдуманной заградительной ценой.
    final zKeys = [
      for (final cropId in cropIds)
        if (cropsById[cropId]!.isPurchasable) cropId,
    ];

    final zStart = xKeys.length + yKeys.length;
    final n = zStart + zKeys.length;
    final objective = List<double>.filled(n, 0);
    for (var i = 0; i < xKeys.length; i++) {
      objective[i] = cropsById[xKeys[i].cropId]!.costByLand[xKeys[i].landId]!;
    }
    for (var i = 0; i < yKeys.length; i++) {
      final bp = bpByKey['${yKeys[i].breedId}|${yKeys[i].productId}']!;
      objective[xKeys.length + i] = bp.annualCostPerHead;
    }
    for (var i = 0; i < zKeys.length; i++) {
      objective[zStart + i] = cropsById[zKeys[i]]!.purchasePricePerTon!;
    }

    final constraints = <List<double>>[];
    final rhs = <double>[];

    // (1.2) по каждой категории угодий: Σ_j x[k][j] ≤ s[k]
    if (!ignoreLandLimits) {
      for (final land in [...input.lands]..sort((a, b) => a.id.compareTo(b.id))) {
        final row = List<double>.filled(n, 0);
        for (var i = 0; i < xKeys.length; i++) {
          if (xKeys[i].landId == land.id) row[i] = 1;
        }
        constraints.add(row);
        rhs.add(land.areaHa);
      }
    }

    // (1.3) кормовой баланс с закупкой:
    //   Σ_k a[k][j]·x[k][j] + z[j] ≥ Σ q[j][h][l]·y[h][l]
    // приводим к виду «≤», умножая на −1
    for (final cropId in cropIds) {
      final crop = cropsById[cropId]!;
      final row = List<double>.filled(n, 0);
      for (var i = 0; i < xKeys.length; i++) {
        if (xKeys[i].cropId == cropId) {
          row[i] = -crop.yieldByLand[xKeys[i].landId]!;
        }
      }
      for (var i = 0; i < yKeys.length; i++) {
        final bp = bpByKey['${yKeys[i].breedId}|${yKeys[i].productId}']!;
        final need = bp.feedNeed[cropId];
        if (need != null && need != 0) row[xKeys.length + i] = need;
      }
      final zIndex = zKeys.indexOf(cropId);
      if (zIndex != -1) row[zStart + zIndex] = -1;
      constraints.add(row);
      rhs.add(0);
    }

    // (1.4) план производства: Σ_l v[h][l]·y[h][l] ≥ b[h]
    final productIds = input.productionPlan.keys.toList()..sort();
    for (final productId in productIds) {
      final row = List<double>.filled(n, 0);
      for (var i = 0; i < yKeys.length; i++) {
        if (yKeys[i].productId != productId) continue;
        final bp = bpByKey['${yKeys[i].breedId}|${yKeys[i].productId}']!;
        row[xKeys.length + i] = -bp.yieldPerHead;
      }
      constraints.add(row);
      rhs.add(-input.productionPlan[productId]!);
    }

    // (1.7) предел поголовья по породе: Σ_h y[h][l] ≤ n[l].
    // Строка добавляется только для пород, которым хозяйство задало
    // границу: пустое ограничение «≤ +∞» лишь замедлило бы симплекс.
    final limitedBreeds = input.breedLimits.keys.toList()..sort();
    for (final breedId in limitedBreeds) {
      final limit = input.breedLimits[breedId]!;
      final row = List<double>.filled(n, 0);
      var touchesProblem = false;
      for (var i = 0; i < yKeys.length; i++) {
        if (yKeys[i].breedId == breedId) {
          row[xKeys.length + i] = 1;
          touchesProblem = true;
        }
      }
      if (!touchesProblem) continue;
      constraints.add(row);
      rhs.add(limit);
    }

    return _FarmModel._(
      input: input,
      xKeys: xKeys,
      yKeys: yKeys,
      zKeys: zKeys,
      problem: LpProblem(objective: objective, constraints: constraints, rhs: rhs),
      integerVariables: {
        for (var i = 0; i < yKeys.length; i++) xKeys.length + i,
      },
    );
  }

  /// Насколько не хватает земли, если план недостижим: решаем ту же
  /// задачу без ограничения (1.2) и смотрим, сколько земли потребовал бы
  /// наименее затратный план.
  ///
  /// После появления закупки кормов (1.3) нехватка пашни сама по себе
  /// план уже не срывает — недостающее зерно и сено модель купит.
  /// Поэтому здесь почти всегда всплывают пастбища: пастбищную траву
  /// купить нельзя, и её дефицит остаётся настоящей нехваткой земли.
  double? estimateLandShortage() {
    final relaxed = _FarmModel.build(input, ignoreLandLimits: true);
    final result = BranchAndBound.solve(
      relaxed.problem,
      integerVariables: relaxed.integerVariables,
    );
    if (!result.isOptimal) return null;

    final requiredByLand = <String, double>{};
    for (var i = 0; i < relaxed.xKeys.length; i++) {
      final landId = relaxed.xKeys[i].landId;
      requiredByLand[landId] = (requiredByLand[landId] ?? 0) + result.x[i];
    }
    final availableByLand = {for (final l in input.lands) l.id: l.areaHa};

    var missing = 0.0;
    for (final entry in requiredByLand.entries) {
      final gap = entry.value - (availableByLand[entry.key] ?? 0);
      if (gap > 0) missing += gap;
    }
    return double.parse(missing.toStringAsFixed(1));
  }

  OptimizationResult toResult(MilpResult result) {
    const areaTolerance = 1e-6;

    final cropArea = <CropAreaAllocation>[];
    for (var i = 0; i < xKeys.length; i++) {
      final area = result.x[i];
      if (area <= areaTolerance) continue;
      // Площадь не округляем: округлённое значение уже не удовлетворяло бы
      // кормовому балансу в точности. Для показа округляет экран (Num.area),
      // а данные остаются согласованными с ограничениями модели.
      cropArea.add(CropAreaAllocation(
        landId: xKeys[i].landId,
        cropId: xKeys[i].cropId,
        areaHa: area,
      ));
    }

    final livestock = <LivestockAllocation>[];
    for (var i = 0; i < yKeys.length; i++) {
      final heads = result.x[xKeys.length + i].round();
      if (heads <= 0) continue;
      livestock.add(LivestockAllocation(
        breedId: yKeys[i].breedId,
        productId: yKeys[i].productId,
        heads: heads,
      ));
    }

    // Закупка тоннами: округляем до килограммов, иначе в отчёт
    // попадает «докупить 0,0000001 т» — след погрешности симплекса,
    // а не решение хозяйства.
    const purchaseTolerance = 1e-3;
    final cropsById = {for (final c in input.crops) c.id: c};
    final zStart = xKeys.length + yKeys.length;
    final feedPurchase = <FeedPurchase>[];
    for (var i = 0; i < zKeys.length; i++) {
      final tons = result.x[zStart + i];
      if (tons <= purchaseTolerance) continue;
      final price = cropsById[zKeys[i]]!.purchasePricePerTon!;
      feedPurchase.add(FeedPurchase(
        cropId: zKeys[i],
        tons: tons,
        cost: double.parse((price * tons).toStringAsFixed(2)),
      ));
    }

    return OptimizationResult(
      status: SolveStatus.optimal,
      totalCost: double.parse(result.objective.toStringAsFixed(2)),
      cropArea: cropArea,
      livestock: livestock,
      feedPurchase: feedPurchase,
      solverVersion: LocalFarmSolver.version,
    );
  }
}
