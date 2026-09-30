/// Исход решения задачи линейного программирования.
enum LpStatus { optimal, infeasible, unbounded }

class LpResult {
  const LpResult({required this.status, this.x = const [], this.objective = 0});

  final LpStatus status;

  /// Значения переменных в оптимуме.
  final List<double> x;

  /// Значение целевой функции.
  final double objective;

  bool get isOptimal => status == LpStatus.optimal;
}

/// Задача линейного программирования в виде
///
///     минимизировать   cᵀx
///     при условиях     Ax ≤ b,  x ≥ 0
///
/// Ограничения «≥» приводятся к этому виду умножением строки на −1
/// вызывающей стороной, поэтому правая часть может быть отрицательной.
class LpProblem {
  LpProblem({
    required this.objective,
    required this.constraints,
    required this.rhs,
  })  : assert(constraints.length == rhs.length),
        assert(constraints.every((row) => row.length == objective.length));

  final List<double> objective;
  final List<List<double>> constraints;
  final List<double> rhs;

  int get variableCount => objective.length;
  int get constraintCount => constraints.length;
}

/// Двухфазный симплекс-метод на плотной таблице.
///
/// Задача, которую решает приложение, мала — единицы категорий угодий,
/// культур и пород, то есть десятки переменных. Для такого размера
/// плотная таблица проще и надёжнее разреженных схем, а правило Бланда
/// защищает от зацикливания в вырожденных случаях.
class Simplex {
  Simplex._({
    required List<List<double>> tableau,
    required List<int> basis,
    required int rows,
    required int cols,
    required Set<int> forbidden,
  })  : _tableau = tableau,
        _basis = basis,
        _rows = rows,
        _cols = cols,
        _forbidden = forbidden;

  /// Допуск сравнения с нулём. Подобран под масштаб задачи: затраты
  /// исчисляются десятками тысяч сомов, площади — единицами гектаров.
  static const eps = 1e-9;

  /// Порог, ниже которого сумма искусственных переменных считается
  /// нулевой. Мягче eps: за фазу 1 накапливается погрешность.
  static const _feasibilityTolerance = 1e-7;

  /// Предохранитель от бесконечного цикла при численных неприятностях.
  static const _maxIterations = 20000;

  final List<List<double>> _tableau;
  final List<int> _basis;
  final int _rows;
  final int _cols;

  /// Столбцы, которым запрещено входить в базис. После первой фазы
  /// сюда попадают искусственные переменные: обнулять их столбцы
  /// нельзя (искусственная переменная может остаться в базисе
  /// с нулевым значением на вырожденной задаче), а вот запретить
  /// им возвращаться — можно и нужно.
  final Set<int> _forbidden;

  static LpResult solve(LpProblem problem) {
    final m = problem.constraintCount;
    final n = problem.variableCount;

    if (m == 0) {
      final unbounded = problem.objective.any((c) => c < -eps);
      return unbounded
          ? const LpResult(status: LpStatus.unbounded)
          : LpResult(status: LpStatus.optimal, x: List.filled(n, 0));
    }

    // Приводим к равенствам: Ax + s = b. Строки с отрицательной правой
    // частью разворачиваем, чтобы b стало неотрицательным; у слака
    // при этом коэффициент −1, и такая строка требует искусственной
    // переменной.
    final flippedRows = <int>[];
    for (var i = 0; i < m; i++) {
      if (problem.rhs[i] < 0) flippedRows.add(i);
    }

    final artificialCount = flippedRows.length;
    final artificialStart = n + m;
    final totalCols = artificialStart + artificialCount;

    // Строки ограничений + строка целевой функции;
    // последний столбец — правая часть.
    final tableau = List.generate(m + 1, (_) => List<double>.filled(totalCols + 1, 0));
    final basis = List<int>.filled(m, 0);

    for (var i = 0; i < m; i++) {
      final flip = problem.rhs[i] < 0;
      final sign = flip ? -1.0 : 1.0;
      for (var j = 0; j < n; j++) {
        tableau[i][j] = sign * problem.constraints[i][j];
      }
      tableau[i][n + i] = sign;
      tableau[i][totalCols] = sign * problem.rhs[i];
      basis[i] = n + i;
    }

    for (var k = 0; k < artificialCount; k++) {
      final row = flippedRows[k];
      tableau[row][artificialStart + k] = 1.0;
      basis[row] = artificialStart + k;
    }

    final simplex = Simplex._(
      tableau: tableau,
      basis: basis,
      rows: m,
      cols: totalCols,
      forbidden: {},
    );

    if (artificialCount > 0) {
      // Фаза 1: минимизируем сумму искусственных переменных.
      for (var k = 0; k < artificialCount; k++) {
        tableau[m][artificialStart + k] = 1.0;
      }
      for (final row in flippedRows) {
        simplex._addRowToObjective(row, -1.0);
      }

      if (!simplex._run()) return const LpResult(status: LpStatus.unbounded);

      final artificialSum = -tableau[m][totalCols];
      if (artificialSum > _feasibilityTolerance) {
        return const LpResult(status: LpStatus.infeasible);
      }

      simplex._driveArtificialsOutOfBasis(artificialStart);
      // Вернуться в базис им уже нельзя.
      for (var k = 0; k < artificialCount; k++) {
        simplex._forbidden.add(artificialStart + k);
      }
    }

    // Фаза 2: исходная целевая функция.
    for (var j = 0; j <= totalCols; j++) {
      tableau[m][j] = 0;
    }
    for (var j = 0; j < n; j++) {
      tableau[m][j] = problem.objective[j];
    }
    for (var i = 0; i < m; i++) {
      final cost = basis[i] < n ? problem.objective[basis[i]] : 0.0;
      if (cost != 0) simplex._addRowToObjective(i, -cost);
    }

    if (!simplex._run()) return const LpResult(status: LpStatus.unbounded);

    final x = List<double>.filled(n, 0);
    for (var i = 0; i < m; i++) {
      if (basis[i] < n) {
        // отрицательные значения возможны только как погрешность
        x[basis[i]] = tableau[i][totalCols].clamp(0, double.infinity);
      }
    }
    var objective = 0.0;
    for (var j = 0; j < n; j++) {
      objective += problem.objective[j] * x[j];
    }
    return LpResult(status: LpStatus.optimal, x: x, objective: objective);
  }

  void _addRowToObjective(int row, double factor) {
    for (var j = 0; j <= _cols; j++) {
      _tableau[_rows][j] += factor * _tableau[row][j];
    }
  }

  /// Итерации симплекса. Возвращает false, если задача неограничена.
  bool _run() {
    for (var iteration = 0; iteration < _maxIterations; iteration++) {
      // Правило Бланда: входит переменная с наименьшим индексом среди
      // подходящих. Медленнее «наибольшего коэффициента», зато
      // исключает зацикливание на вырожденных задачах.
      var enter = -1;
      for (var j = 0; j < _cols; j++) {
        if (_forbidden.contains(j)) continue;
        if (_tableau[_rows][j] < -eps) {
          enter = j;
          break;
        }
      }
      if (enter == -1) return true; // оптимум достигнут

      var leave = -1;
      var bestRatio = double.infinity;
      for (var i = 0; i < _rows; i++) {
        if (_tableau[i][enter] <= eps) continue;
        final ratio = _tableau[i][_cols] / _tableau[i][enter];
        if (ratio < bestRatio - eps) {
          bestRatio = ratio;
          leave = i;
        } else if (ratio < bestRatio + eps && leave != -1 && _basis[i] < _basis[leave]) {
          // при равных отношениях — строка с меньшим индексом базисной
          // переменной, это вторая половина правила Бланда
          leave = i;
        }
      }
      if (leave == -1) return false; // неограниченная задача

      _pivot(leave, enter);
    }
    return true;
  }

  void _pivot(int row, int col) {
    final pivot = _tableau[row][col];
    for (var j = 0; j <= _cols; j++) {
      _tableau[row][j] /= pivot;
    }
    for (var i = 0; i <= _rows; i++) {
      if (i == row) continue;
      final factor = _tableau[i][col];
      if (factor == 0) continue;
      for (var j = 0; j <= _cols; j++) {
        _tableau[i][j] -= factor * _tableau[row][j];
      }
    }
    _basis[row] = col;
  }

  /// Выводит искусственные переменные из базиса после первой фазы.
  /// Если в строке не нашлось ненулевого коэффициента при исходной
  /// переменной, строка линейно зависима — искусственная переменная
  /// остаётся в базисе с нулевым значением и просто не мешает.
  void _driveArtificialsOutOfBasis(int artificialStart) {
    for (var i = 0; i < _rows; i++) {
      if (_basis[i] < artificialStart) continue;
      for (var j = 0; j < artificialStart; j++) {
        if (_tableau[i][j].abs() > eps) {
          _pivot(i, j);
          break;
        }
      }
    }
  }
}
