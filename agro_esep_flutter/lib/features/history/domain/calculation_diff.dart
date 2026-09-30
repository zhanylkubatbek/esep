import '../../../data/models/calculation_record.dart';
import '../../../data/normatives/normatives.dart';

/// Изменение одной строки при сравнении двух расчётов.
class DiffRow {
  const DiffRow({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final double before;
  final double after;

  double get delta => after - before;
  bool get isNew => before == 0 && after > 0;
  bool get isGone => before > 0 && after == 0;
  bool get isUnchanged => (delta).abs() < 0.05;
}

/// Сравнение двух сохранённых расчётов.
///
/// В материалах проекта заявлено «сравнение производственных сценариев».
/// Сравниваются именно два выполненных расчёта, а не расчёт с «как
/// сейчас»: данных о текущем состоянии хозяйства приложение не собирает,
/// и придумывать их было бы обманом.
class CalculationDiff {
  const CalculationDiff({
    required this.before,
    required this.after,
    required this.crops,
    required this.livestock,
    required this.comparable,
  });

  final CalculationRecord before;
  final CalculationRecord after;
  final List<DiffRow> crops;
  final List<DiffRow> livestock;

  /// false, если расчёты считались на разных нормативах — тогда
  /// разница в сомах говорит не о решении хозяйства, а о смене базы.
  /// false, если расчёты сделаны на разных версиях нормативов: тогда
  /// разница в затратах говорит о смене базы, а не о решении хозяйства.
  /// Текст предупреждения собирает экран — он знает язык.
  final bool comparable;

  double get costBefore => before.result?.totalCost ?? 0;
  double get costAfter => after.result?.totalCost ?? 0;
  double get costDelta => costAfter - costBefore;

  /// Экономия в процентах. Отрицательное значение — подорожание.
  int get savingsPercent =>
      costBefore == 0 ? 0 : ((costBefore - costAfter) / costBefore * 100).round();

  bool get isCheaper => costAfter < costBefore;

  static CalculationDiff of(
    CalculationRecord a,
    CalculationRecord b,
    Normatives normatives, {
    /// Язык названий культур и пород в подписях строк.
    String languageCode = 'ru',
  }) {
    // «До» — тот, что выполнен раньше
    final (before, after) =
        a.createdAt.isBefore(b.createdAt) ? (a, b) : (b, a);

    final names = normatives.namesFor(languageCode);

    Map<String, double> cropAreas(CalculationRecord r) {
      final map = <String, double>{};
      for (final a in r.result?.cropArea ?? const []) {
        map.update(a.cropId, (v) => v + a.areaHa, ifAbsent: () => a.areaHa);
      }
      return map;
    }

    Map<String, double> heads(CalculationRecord r) {
      final map = <String, double>{};
      for (final l in r.result?.livestock ?? const []) {
        final key = '${l.breedId}|${l.productId}';
        map.update(key, (v) => v + l.heads, ifAbsent: () => l.heads.toDouble());
      }
      return map;
    }

    final cropsBefore = cropAreas(before);
    final cropsAfter = cropAreas(after);
    final crops = [
      for (final id in {...cropsBefore.keys, ...cropsAfter.keys}.toList()..sort())
        DiffRow(
          label: names.crop(id),
          before: cropsBefore[id] ?? 0,
          after: cropsAfter[id] ?? 0,
        ),
    ]..sort((x, y) => y.after.compareTo(x.after));

    final headsBefore = heads(before);
    final headsAfter = heads(after);
    final livestock = [
      for (final key in {...headsBefore.keys, ...headsAfter.keys}.toList()..sort())
        DiffRow(
          label: '${names.breed(key.split('|').first)}'
              ' · ${names.product(key.split('|').last)}',
          before: headsBefore[key] ?? 0,
          after: headsAfter[key] ?? 0,
        ),
    ]..sort((x, y) => y.after.compareTo(x.after));

    final sameNormatives = before.normativesVersion == after.normativesVersion;

    return CalculationDiff(
      before: before,
      after: after,
      crops: crops,
      livestock: livestock,
      comparable: sameNormatives,
    );
  }
}
