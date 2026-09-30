import 'simplex.dart';

class MilpResult {
  const MilpResult({
    required this.status,
    this.x = const [],
    this.objective = 0,
    this.exploredNodes = 0,
  });

  final LpStatus status;
  final List<double> x;
  final double objective;

  /// Сколько подзадач пришлось решить. Нужно не пользователю,
  /// а для проверки, что перебор не разрастается.
  final int exploredNodes;

  bool get isOptimal => status == LpStatus.optimal;
}

/// Метод ветвей и границ поверх симплекса.
///
/// В задаче хозяйства целочисленны только переменные поголовья
/// y[h][l] — их единицы, а не десятки. Площади посевов x[k][j]
/// остаются непрерывными: гектар делится.
class BranchAndBound {
  /// Отклонение от целого, которое считается округлением, а не
  /// дробностью. Симплекс возвращает значения с погрешностью,
  /// и 71.9999999997 — это 72, а не повод ветвиться.
  static const integerTolerance = 1e-6;

  /// Предохранитель: при разумных данных перебор укладывается
  /// в десятки узлов, тысячи означают вырожденную постановку.
  static const maxNodes = 20000;

  /// [integerVariables] — индексы переменных, обязанных быть целыми.
  static MilpResult solve(
    LpProblem problem, {
    required Set<int> integerVariables,
  }) {
    final root = Simplex.solve(problem);
    if (!root.isOptimal) {
      return MilpResult(status: root.status, exploredNodes: 1);
    }
    if (_fractionalIndex(root.x, integerVariables) == null) {
      // релаксация сразу дала целые значения — ветвиться незачем
      return MilpResult(
        status: LpStatus.optimal,
        x: root.x,
        objective: root.objective,
        exploredNodes: 1,
      );
    }

    // Обход в глубину: быстрее находит первое целое решение,
    // а чем раньше найден рекорд, тем больше ветвей отсекается.
    final stack = <_Node>[_Node(problem, root)];
    List<double>? best;
    var bestObjective = double.infinity;
    var explored = 0;

    while (stack.isNotEmpty) {
      if (explored >= maxNodes) break;
      final node = stack.removeLast();
      explored++;

      final relaxation = node.relaxation ?? Simplex.solve(node.problem);
      if (!relaxation.isOptimal) continue;

      // Отсечение по границе: минимум этой ветви уже не лучше рекорда.
      if (relaxation.objective >= bestObjective - integerTolerance) continue;

      final fractional = _fractionalIndex(relaxation.x, integerVariables);
      if (fractional == null) {
        best = relaxation.x;
        bestObjective = relaxation.objective;
        continue;
      }

      final value = relaxation.x[fractional];
      final floor = value.floorToDouble();
      final ceil = value.ceilToDouble();

      // Ветвь «не больше floor» и ветвь «не меньше ceil».
      // Кладём в стек так, чтобы первой разбиралась ветвь вверх:
      // она обычно быстрее даёт допустимое решение, потому что
      // ограничения плана — «не меньше».
      stack.add(_Node(_withBound(node.problem, fractional, floor, upper: true), null));
      stack.add(_Node(_withBound(node.problem, fractional, ceil, upper: false), null));
    }

    if (best == null) {
      return MilpResult(status: LpStatus.infeasible, exploredNodes: explored);
    }

    // Значения целых переменных доводим до точных целых: дальше они
    // показываются как поголовье, и 71.9999999 читалось бы как 71.
    final rounded = List<double>.of(best);
    for (final i in integerVariables) {
      rounded[i] = rounded[i].roundToDouble();
    }

    var objective = 0.0;
    for (var j = 0; j < rounded.length; j++) {
      objective += problem.objective[j] * rounded[j];
    }

    return MilpResult(
      status: LpStatus.optimal,
      x: rounded,
      objective: objective,
      exploredNodes: explored,
    );
  }

  /// Индекс первой переменной, которая обязана быть целой, но целой
  /// не получилась. null — все целочисленные требования соблюдены.
  static int? _fractionalIndex(List<double> x, Set<int> integerVariables) {
    for (final i in integerVariables) {
      if (i >= x.length) continue;
      final distance = (x[i] - x[i].roundToDouble()).abs();
      if (distance > integerTolerance) return i;
    }
    return null;
  }

  /// Копия задачи с дополнительным ограничением на одну переменную:
  /// `x[index] ≤ bound` либо `x[index] ≥ bound`.
  static LpProblem _withBound(
    LpProblem base,
    int index,
    double bound, {
    required bool upper,
  }) {
    final row = List<double>.filled(base.variableCount, 0);
    row[index] = upper ? 1.0 : -1.0;

    return LpProblem(
      objective: base.objective,
      constraints: [...base.constraints, row],
      rhs: [...base.rhs, upper ? bound : -bound],
    );
  }
}

class _Node {
  const _Node(this.problem, this.relaxation);

  final LpProblem problem;

  /// Уже посчитанная релаксация корня — чтобы не решать дважды.
  final LpResult? relaxation;
}
