import 'package:agro_esep/core/formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const nbsp = ' ';

  group('целые числа', () {
    test('разряды разделяются неразрывным пробелом', () {
      expect(Num.integer(5542462), '5${nbsp}542${nbsp}462');
      expect(Num.integer(1000), '1${nbsp}000');
      expect(Num.integer(999), '999');
      expect(Num.integer(0), '0');
    });

    test('единица приклеивается неразрывным пробелом', () {
      expect(Num.withUnit(Num.integer(5542462), 'сом'),
          ['5', '542', '462', 'сом'].join(nbsp));
      expect(Num.withUnit(Num.area(25.6), 'га'), ['25,6', 'га'].join(nbsp));
    });
  });

  group('площади', () {
    test('целое значение выводится без ", 0"', () {
      expect(Num.area(120), '120');
      expect(Num.area(320), '320');
    });

    test('дробное значение — с запятой, а не с точкой', () {
      expect(Num.area(25.6), '25,6');
      expect(Num.area(82.6), '82,6');
      expect(Num.area(0.5), '0,5');
    });

    test('округление до одного знака', () {
      expect(Num.area(25.64), '25,6');
      expect(Num.area(25.66), '25,7');
      // Округление десятых переносится в целую часть, а не теряется:
      // 9,96 — это «10», а не «9,0».
      expect(Num.area(9.96), '10');
      expect(Num.area(99.95), '100');
    });

    test('крупные дробные площади тоже разделяются по разрядам', () {
      expect(Num.area(1234.5), '1${nbsp}234,5');
    });
  });

  test('дата и время', () {
    expect(Num.dateTime(DateTime(2026, 8, 8, 9, 44)), '08.08.2026, 09:44');
    expect(Num.dateTime(DateTime(2026, 12, 31, 23, 5)), '31.12.2026, 23:05');
  });
}
