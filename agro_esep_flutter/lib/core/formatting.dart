/// Единое форматирование чисел. Русская запись: запятая как
/// десятичный разделитель и неразрывный пробел между разрядами
/// («5 542 462 сом», «25,6 га»), как в макетах и на сайте.
abstract final class Num {
  /// Неразрывный, чтобы «5 542 462» не переносилось по строкам.
  static const _thousandsSeparator = ' ';

  /// Число с одним знаком после запятой, но без «,0» у целых:
  /// 120 -> «120», 25.6 -> «25,6».
  ///
  /// Округление до десятых делается один раз и до разбора на части.
  /// Если брать целую часть от исходного числа, а десятые округлять
  /// отдельно, то 9,96 печатается как «9,0»: целая часть осталась
  /// от девяти, а десятые уже перевалили за десять.
  static String area(double value) {
    final rounded = (value * 10).roundToDouble() / 10;
    if (rounded == rounded.roundToDouble()) return integer(rounded);

    final sign = rounded < 0 ? '-' : '';
    final magnitude = rounded.abs();
    final whole = integer(magnitude.truncateToDouble());
    final tenths = (magnitude * 10).round().remainder(10);
    return '$sign$whole,$tenths';
  }

  /// Целое число с разделением разрядов: 5542462 -> «5 542 462».
  static String integer(double value) {
    final negative = value < 0;
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(_thousandsSeparator);
      buffer.write(digits[i]);
    }
    return negative ? '-$buffer' : buffer.toString();
  }

  /// Число и единица, склеенные неразрывным пробелом: «120 га», «100 т/год».
  static String withUnit(String value, String unit) =>
      value + _thousandsSeparator + unit;

  /// Дата и время расчёта: «08.08.2026, 09:44».
  static String dateTime(DateTime d) =>
      '${_two(d.day)}.${_two(d.month)}.${d.year}, ${_two(d.hour)}:${_two(d.minute)}';

  static String _two(int v) => v.toString().padLeft(2, '0');
}
