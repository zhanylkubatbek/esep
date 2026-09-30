import 'dart:typed_data';

import 'package:excel/excel.dart';

/// Что именно не так с таблицей. Разбор — слой данных, и текста
/// он не хранит: формулировку по коду собирает экран, который знает язык.
enum ImportIssueKind {
  /// Файл не открылся как .xlsx. [ImportIssue.detail] — текст исключения.
  fileUnreadable,
  sheetMissing,
  sheetEmpty,
  noRows,
  idAndNameRequired,

  /// [ImportIssue.detail] — идентификатор угодья из файла.
  unknownLand,
  numbersRequired,
  nameRequired,

  /// [ImportIssue.detail] — идентификатор культуры из заголовка.
  unknownCropInHeader,
  feedColumnsMissing,

  /// [ImportIssue.detail] — идентификатор продукции из файла.
  unknownProduct,
  yieldMustBePositive,
  costMustBeNumber,
  feedNeedEmpty,
}

/// Ошибка разбора с указанием листа и строки — сотрудник института
/// должен понимать, что именно исправить в таблице, а не видеть
/// «файл не подходит».
///
/// [sheet] — имя листа как оно записано в файле; для ошибок уровня
/// файла лист не указывается ([sheet] равен null).
class ImportIssue {
  const ImportIssue(this.sheet, this.row, this.kind, [this.detail]);

  final String? sheet;
  final int? row;
  final ImportIssueKind kind;

  /// Значение из файла, о котором идёт речь, если оно есть.
  final String? detail;

  @override
  String toString() => 'ImportIssue($kind, sheet: $sheet, row: $row'
      '${detail == null ? '' : ', detail: $detail'})';
}

class ImportResult {
  const ImportResult({required this.json, required this.issues});

  /// null, если разбор не удался.
  final Map<String, dynamic>? json;
  final List<ImportIssue> issues;

  bool get isSuccess => json != null && issues.isEmpty;
}

/// Разбор нормативной базы из .xlsx.
///
/// Excel, а не CSV: Windows-версия Excel по умолчанию сохраняет CSV
/// в cp1251, и кириллица в названиях культур и пород приезжает
/// испорченной. Внутри .xlsx текст всегда в UTF-8.
///
/// Ожидаемые листы (имена столбцов — в первой строке):
///   Угодья:    id | Название
///   Культуры:  id | Название | Угодье | Урожайность | Затраты | Цена закупки
///   Продукция: id | Название | Единица
///   Породы:    Порода id | Порода | Продукция id | Выход | Затраты | <культура id>…
///   Версия:    version | значение
///
/// Кыргызские названия — необязательные столбцы [columnNameKy],
/// [columnUnitKy] и [columnBreedNameKy]. Без них база одноязычная,
/// и кыргызский интерфейс показывает русские названия справочника:
/// см. `Normatives.namesFor`.
abstract final class ExcelNormativesImport {
  static const sheetLands = 'Угодья';
  static const sheetCrops = 'Культуры';
  static const sheetProducts = 'Продукция';
  static const sheetBreeds = 'Породы';
  static const sheetMeta = 'Версия';

  /// Заголовки необязательных столбцов с переводом.
  ///
  /// Ищутся по имени, а не по номеру: на листе «Породы» справа стоит
  /// переменное число столбцов с кормами, и фиксированный номер
  /// столкнулся бы с ними. Заодно перевод можно дописать к готовой
  /// таблице, не сдвигая обязательные столбцы.
  static const columnNameKy = 'Название (кырг.)';
  static const columnUnitKy = 'Единица (кырг.)';
  static const columnBreedNameKy = 'Порода (кырг.)';

  /// Единица продукции, если столбец не заполнен. Пара значений,
  /// а не одна строка: иначе в кыргызском интерфейсе оставалось
  /// бы русское «т/год».
  static const defaultUnit = 'т/год';
  static const defaultUnitKy = 'т/жыл';

  static ImportResult parse(Uint8List bytes) {
    final issues = <ImportIssue>[];
    late final Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (e) {
      return ImportResult(
        json: null,
        issues: [ImportIssue(null, null, ImportIssueKind.fileUnreadable, '$e')],
      );
    }

    for (final required in [sheetLands, sheetCrops, sheetProducts, sheetBreeds]) {
      if (!excel.tables.containsKey(required)) {
        issues.add(ImportIssue(required, null, ImportIssueKind.sheetMissing));
      }
    }
    if (issues.isNotEmpty) return ImportResult(json: null, issues: issues);

    final lands = _parseLands(excel, issues);
    final crops = _parseCrops(excel, issues, lands.map((l) => l['id'] as String).toSet());
    final products = _parseProducts(excel, issues);
    final breeds = _parseBreeds(
      excel,
      issues,
      cropIds: crops.map((c) => c['id'] as String).toSet(),
      productIds: products.map((p) => p['id'] as String).toSet(),
    );
    final version = _parseVersion(excel);

    if (issues.isNotEmpty) return ImportResult(json: null, issues: issues);

    return ImportResult(
      json: {
        'version': version,
        'is_demo': false,
        'lands': lands,
        'crops': crops,
        'products': products,
        'breed_products': breeds,
        'plausibility': {'max_milk_t_per_ha': 1.2, 'max_meat_t_per_ha': 0.12},
      },
      issues: const [],
    );
  }

  static List<Map<String, dynamic>> _parseLands(Excel excel, List<ImportIssue> issues) {
    final rows = _dataRows(excel, sheetLands);
    final nameKy = _columnByHeader(excel, sheetLands, columnNameKy);
    final result = <Map<String, dynamic>>[];
    for (final (index, row) in rows.indexed) {
      final id = _text(row, 0);
      final name = _text(row, 1);
      if (id.isEmpty && name.isEmpty) continue;
      if (id.isEmpty || name.isEmpty) {
        issues.add(
            ImportIssue(sheetLands, index + 2, ImportIssueKind.idAndNameRequired));
        continue;
      }
      result.add({
        'id': id,
        'name': name,
        ..._translation('name_ky', row, nameKy),
      });
    }
    if (result.isEmpty) {
      issues.add(ImportIssue(sheetLands, null, ImportIssueKind.noRows));
    }
    return result;
  }

  static List<Map<String, dynamic>> _parseCrops(
    Excel excel,
    List<ImportIssue> issues,
    Set<String> landIds,
  ) {
    final rows = _dataRows(excel, sheetCrops);
    final nameKy = _columnByHeader(excel, sheetCrops, columnNameKy);
    // одна культура занимает несколько строк — по строке на каждое угодье
    final byId = <String, Map<String, dynamic>>{};
    for (final (index, row) in rows.indexed) {
      final id = _text(row, 0);
      if (id.isEmpty) continue;
      final line = index + 2;
      final landId = _text(row, 2);
      if (!landIds.contains(landId)) {
        issues.add(
            ImportIssue(sheetCrops, line, ImportIssueKind.unknownLand, landId));
        continue;
      }
      final yieldValue = _number(row, 3);
      final cost = _number(row, 4);
      if (yieldValue == null || cost == null) {
        issues.add(
            ImportIssue(sheetCrops, line, ImportIssueKind.numbersRequired));
        continue;
      }
      final crop = byId.putIfAbsent(
        id,
        () => {
          'id': id,
          'name': _text(row, 1),
          'yield_by_land': <String, double>{},
          'cost_by_land': <String, double>{},
        },
      );
      (crop['yield_by_land'] as Map<String, double>)[landId] = yieldValue;
      (crop['cost_by_land'] as Map<String, double>)[landId] = cost;

      // Цена закупки — необязательный столбец: культура без цены
      // просто не участвует в закупке (1.3), и это законное состояние,
      // а не ошибка таблицы. Одна культура занимает несколько строк,
      // цена у неё общая — берём первую заполненную.
      final price = _number(row, 5);
      if (price != null && price > 0 && !crop.containsKey('purchase_price_per_ton')) {
        crop['purchase_price_per_ton'] = price;
      }

      // Перевод у культуры тоже один на все её строки, и заполнен он
      // может быть в любой из них.
      if (!crop.containsKey('name_ky')) {
        crop.addAll(_translation('name_ky', row, nameKy));
      }
    }
    if (byId.isEmpty) {
      issues.add(ImportIssue(sheetCrops, null, ImportIssueKind.noRows));
    }
    return byId.values.toList();
  }

  static List<Map<String, dynamic>> _parseProducts(Excel excel, List<ImportIssue> issues) {
    final rows = _dataRows(excel, sheetProducts);
    final nameKy = _columnByHeader(excel, sheetProducts, columnNameKy);
    final unitKy = _columnByHeader(excel, sheetProducts, columnUnitKy);
    final result = <Map<String, dynamic>>[];
    for (final (index, row) in rows.indexed) {
      final id = _text(row, 0);
      if (id.isEmpty) continue;
      final name = _text(row, 1);
      if (name.isEmpty) {
        issues.add(
            ImportIssue(sheetProducts, index + 2, ImportIssueKind.nameRequired));
        continue;
      }
      final unit = _text(row, 2);
      final translations = <String, String>{
        ..._translation('name_ky', row, nameKy),
        ..._translation('unit_ky', row, unitKy),
      };
      // Единица подставляется сразу парой: русское значение без
      // кыргызского оставило бы «т/год» на кыргызском экране.
      if (unit.isEmpty) translations.putIfAbsent('unit_ky', () => defaultUnitKy);
      result.add({
        'id': id,
        'name': name,
        'unit': unit.isEmpty ? defaultUnit : unit,
        ...translations,
      });
    }
    if (result.isEmpty) {
      issues.add(ImportIssue(sheetProducts, null, ImportIssueKind.noRows));
    }
    return result;
  }

  static List<Map<String, dynamic>> _parseBreeds(
    Excel excel,
    List<ImportIssue> issues, {
    required Set<String> cropIds,
    required Set<String> productIds,
  }) {
    final table = excel.tables[sheetBreeds]!;
    if (table.rows.isEmpty) {
      issues.add(ImportIssue(sheetBreeds, null, ImportIssueKind.sheetEmpty));
      return const [];
    }
    final header = table.rows.first;
    final breedNameKy = _columnByHeader(excel, sheetBreeds, columnBreedNameKy);
    // столбцы с 5-го — потребность в кормах, по столбцу на культуру
    final feedColumns = <int, String>{};
    for (var c = 5; c < header.length; c++) {
      // Столбец с переводом стоит в том же хвосте, но кормом не является:
      // иначе его заголовок считался бы неизвестной культурой.
      if (c == breedNameKy) continue;
      final cropId = _cellText(header[c]);
      if (cropId.isEmpty) continue;
      if (!cropIds.contains(cropId)) {
        issues.add(ImportIssue(
            sheetBreeds, 1, ImportIssueKind.unknownCropInHeader, cropId));
        continue;
      }
      feedColumns[c] = cropId;
    }
    if (feedColumns.isEmpty) {
      issues.add(
          ImportIssue(sheetBreeds, 1, ImportIssueKind.feedColumnsMissing));
    }

    final result = <Map<String, dynamic>>[];
    for (final (index, row) in _dataRows(excel, sheetBreeds).indexed) {
      final breedId = _text(row, 0);
      if (breedId.isEmpty) continue;
      final line = index + 2;
      final productId = _text(row, 2);
      if (!productIds.contains(productId)) {
        issues.add(ImportIssue(
            sheetBreeds, line, ImportIssueKind.unknownProduct, productId));
        continue;
      }
      final yieldPerHead = _number(row, 3);
      final cost = _number(row, 4);
      if (yieldPerHead == null || yieldPerHead <= 0) {
        issues.add(
            ImportIssue(sheetBreeds, line, ImportIssueKind.yieldMustBePositive));
        continue;
      }
      if (cost == null || cost < 0) {
        issues.add(
            ImportIssue(sheetBreeds, line, ImportIssueKind.costMustBeNumber));
        continue;
      }
      final feed = <String, double>{};
      for (final entry in feedColumns.entries) {
        final value = _number(row, entry.key);
        if (value != null && value > 0) feed[entry.value] = value;
      }
      if (feed.isEmpty) {
        issues.add(
            ImportIssue(sheetBreeds, line, ImportIssueKind.feedNeedEmpty));
        continue;
      }
      result.add({
        'breed_id': breedId,
        'breed_name': _text(row, 1),
        ..._translation('breed_name_ky', row, breedNameKy),
        'product_id': productId,
        'product_name': '',
        'yield_per_head': yieldPerHead,
        'annual_cost_per_head': cost,
        'feed_need': feed,
      });
    }
    if (result.isEmpty) {
      issues.add(ImportIssue(sheetBreeds, null, ImportIssueKind.noRows));
    }
    return result;
  }

  static String _parseVersion(Excel excel) {
    final table = excel.tables[sheetMeta];
    if (table != null) {
      for (final row in table.rows) {
        if (row.length >= 2 && _cellText(row[0]).toLowerCase() == 'version') {
          final value = _cellText(row[1]);
          if (value.isNotEmpty) return value;
        }
      }
    }
    return 'imported';
  }

  /// Номер столбца с таким заголовком или null, если столбца нет.
  static int? _columnByHeader(Excel excel, String sheet, String header) {
    final rows = excel.tables[sheet]?.rows ?? const [];
    if (rows.isEmpty) return null;
    final target = header.toLowerCase();
    for (final (index, cell) in rows.first.indexed) {
      if (_cellText(cell).toLowerCase() == target) return index;
    }
    return null;
  }

  /// Перевод попадает в базу только когда он действительно есть:
  /// пустая строка означала бы «переведено пустотой», а [Normatives]
  /// ждёт именно отсутствия ключа, чтобы взять русское название.
  static Map<String, String> _translation(
    String field,
    List<Data?> row,
    int? column,
  ) {
    if (column == null) return const {};
    final value = _text(row, column);
    return value.isEmpty ? const {} : {field: value};
  }

  static List<List<Data?>> _dataRows(Excel excel, String sheet) {
    final rows = excel.tables[sheet]?.rows ?? const [];
    return rows.length <= 1 ? const [] : rows.sublist(1);
  }

  static String _text(List<Data?> row, int index) =>
      index < row.length ? _cellText(row[index]) : '';

  static String _cellText(Data? cell) => cell?.value?.toString().trim() ?? '';

  static double? _number(List<Data?> row, int index) {
    if (index >= row.length) return null;
    final value = row[index]?.value;
    if (value == null) return null;
    if (value is IntCellValue) return value.value.toDouble();
    if (value is DoubleCellValue) return value.value;
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }
}
