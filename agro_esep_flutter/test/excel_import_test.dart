import 'dart:typed_data';

import 'package:agro_esep/data/normatives/excel_import.dart';
import 'package:agro_esep/data/normatives/normatives.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

/// Собирает .xlsx той структуры, которую будет вести институт.
Uint8List buildWorkbook({
  bool breakLandReference = false,
  bool missingProductsSheet = false,
  bool kyrgyz = false,
  bool emptyProductUnit = false,
  String? cropYield,
}) {
  final excel = Excel.createExcel();
  excel.delete('Sheet1');

  final lands = excel[ExcelNormativesImport.sheetLands];
  lands.appendRow([
    TextCellValue('id'),
    TextCellValue('Название'),
    if (kyrgyz) TextCellValue(ExcelNormativesImport.columnNameKy),
  ]);
  lands.appendRow([
    TextCellValue('irrigated'),
    TextCellValue('Орошаемая пашня'),
    if (kyrgyz) TextCellValue('Сугат айдоо жери'),
  ]);
  lands.appendRow([
    TextCellValue('rainfed'),
    TextCellValue('Богарная пашня'),
    if (kyrgyz) TextCellValue('Кайрак айдоо жери'),
  ]);

  final crops = excel[ExcelNormativesImport.sheetCrops];
  crops.appendRow([
    TextCellValue('id'),
    TextCellValue('Название'),
    TextCellValue('Угодье'),
    TextCellValue('Урожайность'),
    TextCellValue('Затраты'),
    if (kyrgyz) TextCellValue('Цена закупки'),
    if (kyrgyz) TextCellValue(ExcelNormativesImport.columnNameKy),
  ]);
  // Перевод намеренно оставлен пустым в первой строке культуры
  // и заполнен во второй: в таблице института он стоит не всегда
  // в той строке, с которой культура начинается.
  crops.appendRow([
    TextCellValue('alfalfa'),
    TextCellValue('Люцерна'),
    TextCellValue(breakLandReference ? 'ороша' : 'irrigated'),
    cropYield == null ? DoubleCellValue(8) : TextCellValue(cropYield),
    IntCellValue(15000),
    if (kyrgyz) IntCellValue(12000),
    if (kyrgyz) TextCellValue(''),
  ]);
  crops.appendRow([
    TextCellValue('alfalfa'),
    TextCellValue('Люцерна'),
    TextCellValue('rainfed'),
    DoubleCellValue(4),
    IntCellValue(12000),
    if (kyrgyz) TextCellValue(''),
    if (kyrgyz) TextCellValue('Беде'),
  ]);

  if (!missingProductsSheet) {
    final products = excel[ExcelNormativesImport.sheetProducts];
    products.appendRow([
      TextCellValue('id'),
      TextCellValue('Название'),
      TextCellValue('Единица'),
      if (kyrgyz) TextCellValue(ExcelNormativesImport.columnNameKy),
      if (kyrgyz) TextCellValue(ExcelNormativesImport.columnUnitKy),
    ]);
    products.appendRow([
      TextCellValue('milk'),
      TextCellValue('Молоко'),
      TextCellValue(emptyProductUnit ? '' : 'т/год'),
      if (kyrgyz) TextCellValue('Сүт'),
      if (kyrgyz) TextCellValue(emptyProductUnit ? '' : 'т/жыл'),
    ]);
  }

  final breeds = excel[ExcelNormativesImport.sheetBreeds];
  breeds.appendRow([
    TextCellValue('Порода id'),
    TextCellValue('Порода'),
    TextCellValue('Продукция id'),
    TextCellValue('Выход'),
    TextCellValue('Затраты'),
    TextCellValue('alfalfa'),
    // столбец перевода стоит в том же хвосте, что и корма
    if (kyrgyz) TextCellValue(ExcelNormativesImport.columnBreedNameKy),
  ]);
  breeds.appendRow([
    TextCellValue('alatau'),
    TextCellValue('Алатауская'),
    TextCellValue('milk'),
    DoubleCellValue(4.2),
    IntCellValue(45000),
    DoubleCellValue(2.0),
    if (kyrgyz) TextCellValue('Алатоо тукуму'),
  ]);

  final meta = excel[ExcelNormativesImport.sheetMeta];
  meta.appendRow([TextCellValue('version'), TextCellValue('2026.09.1')]);

  return Uint8List.fromList(excel.save()!);
}

void main() {
  test('корректная таблица разбирается', () {
    final result = ExcelNormativesImport.parse(buildWorkbook());

    expect(result.issues, isEmpty, reason: result.issues.join('; '));
    expect(result.isSuccess, isTrue);
    expect(result.json!['version'], '2026.09.1');
    expect(result.json!['is_demo'], isFalse);
  });

  test('разобранное превращается в рабочие нормативы', () {
    final result = ExcelNormativesImport.parse(buildWorkbook());
    final normatives = Normatives.fromJson(result.json!);

    expect(normatives.lands.map((l) => l.id), ['irrigated', 'rainfed']);
    expect(normatives.crops.single.name, 'Люцерна');
    // одна культура собрана из двух строк — по строке на угодье
    expect(normatives.crops.single.yieldByLand, {'irrigated': 8.0, 'rainfed': 4.0});
    expect(normatives.crops.single.costByLand, {'irrigated': 15000.0, 'rainfed': 12000.0});
    expect(normatives.breedProducts.single.breedName, 'Алатауская');
    expect(normatives.breedProducts.single.feedNeed, {'alfalfa': 2.0});
    expect(normatives.isDemo, isFalse);
  });

  test('кириллица не портится при разборе', () {
    final normatives =
        Normatives.fromJson(ExcelNormativesImport.parse(buildWorkbook()).json!);

    expect(normatives.lands.first.name, 'Орошаемая пашня');
    expect(normatives.products.single.unit, 'т/год');
  });

  group('кыргызские названия из файла', () {
    test('перевод доезжает до кыргызского интерфейса', () {
      final result = ExcelNormativesImport.parse(buildWorkbook(kyrgyz: true));
      expect(result.issues, isEmpty, reason: result.issues.join('; '));

      final names = Normatives.fromJson(result.json!).namesFor('ky');
      expect(names.land('irrigated'), 'Сугат айдоо жери');
      expect(names.land('rainfed'), 'Кайрак айдоо жери');
      expect(names.crop('alfalfa'), 'Беде');
      expect(names.product('milk'), 'Сүт');
      expect(names.unit('milk'), 'т/жыл');
      expect(names.breed('alatau'), 'Алатоо тукуму');
    });

    test('русские названия тот же файл не теряет', () {
      final names = Normatives.fromJson(
        ExcelNormativesImport.parse(buildWorkbook(kyrgyz: true)).json!,
      ).namesFor('ru');

      expect(names.land('irrigated'), 'Орошаемая пашня');
      expect(names.breed('alatau'), 'Алатауская');
      expect(names.unit('milk'), 'т/год');
    });

    test('столбец с переводом породы не принимается за корм', () {
      final normatives = Normatives.fromJson(
        ExcelNormativesImport.parse(buildWorkbook(kyrgyz: true)).json!,
      );

      expect(normatives.breedProducts.single.feedNeed, {'alfalfa': 2.0});
      // цена закупки стоит в том же добавленном хвосте и тоже читается
      expect(normatives.crops.single.purchasePricePerTon, 12000.0);
    });

    test('незаполненная единица подставляется сразу на двух языках', () {
      final normatives = Normatives.fromJson(
        ExcelNormativesImport.parse(
          buildWorkbook(kyrgyz: true, emptyProductUnit: true),
        ).json!,
      );

      expect(normatives.namesFor('ru').unit('milk'), 'т/год');
      expect(normatives.namesFor('ky').unit('milk'), 'т/жыл');
    });

    test('одноязычная база остаётся русской, а не пустой', () {
      final names = Normatives.fromJson(
        ExcelNormativesImport.parse(buildWorkbook()).json!,
      ).namesFor('ky');

      expect(names.land('irrigated'), 'Орошаемая пашня');
      expect(names.breed('alatau'), 'Алатауская');
    });
  });

  test('ссылка на несуществующее угодье указывает лист и строку', () {
    final result = ExcelNormativesImport.parse(buildWorkbook(breakLandReference: true));

    expect(result.isSuccess, isFalse);
    expect(result.json, isNull);
    final issue = result.issues.first;
    expect(issue.sheet, ExcelNormativesImport.sheetCrops);
    expect(issue.row, 2);
    expect(issue.kind, ImportIssueKind.unknownLand);
    // в сообщение попадёт id из файла, а не подставленный
    expect(issue.detail, contains('ороша'));
  });

  test('отсутствующий лист называется по имени', () {
    final result = ExcelNormativesImport.parse(buildWorkbook(missingProductsSheet: true));

    expect(result.isSuccess, isFalse);
    expect(result.issues.single.sheet, ExcelNormativesImport.sheetProducts);
    expect(result.issues.single.kind, ImportIssueKind.sheetMissing);
  });

  test('текст вместо числа не проходит молча', () {
    final result = ExcelNormativesImport.parse(buildWorkbook(cropYield: 'много'));

    expect(result.isSuccess, isFalse);
    expect(result.issues.first.kind, ImportIssueKind.numbersRequired);
  });

  test('число с запятой читается как дробное', () {
    final result = ExcelNormativesImport.parse(buildWorkbook(cropYield: '8,5'));

    expect(result.issues, isEmpty, reason: result.issues.join('; '));
    final normatives = Normatives.fromJson(result.json!);
    expect(normatives.crops.single.yieldByLand['irrigated'], 8.5);
  });

  test('нечитаемый файл не роняет приложение', () {
    final result = ExcelNormativesImport.parse(Uint8List.fromList([1, 2, 3, 4]));

    expect(result.isSuccess, isFalse);
    expect(result.issues, isNotEmpty);
  });
}
