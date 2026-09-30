import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/calculation_record.dart';

/// Локальное хранилище расчётов. На сервере не хранится ничего:
/// данные хозяйства — коммерческая информация третьих лиц.
///
/// Записи лежат JSON-строками, а не типизированными адаптерами Hive:
/// объём мал, а схема ещё будет меняться вместе с моделью института —
/// кодогенерация и миграции адаптеров здесь дороже, чем польза.
abstract interface class CalculationStore {
  Future<void> save(CalculationRecord record);
  Future<void> delete(String id);

  /// Все расчёты, новые сверху.
  List<CalculationRecord> readAll();

}

class HiveCalculationStore implements CalculationStore {
  HiveCalculationStore._(this._box);

  static const boxName = 'calculations';

  final Box<String> _box;

  static Future<HiveCalculationStore> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>(boxName);
    return HiveCalculationStore._(box);
  }

  @override
  Future<void> save(CalculationRecord record) =>
      _box.put(record.id, jsonEncode(record.toJson()));

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  List<CalculationRecord> readAll() {
    final records = <CalculationRecord>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        records.add(
          CalculationRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } on FormatException {
        // запись от несовместимой версии — пропускаем, но не роняем
        // весь список: пользователь не должен терять остальные расчёты
        continue;
      }
    }
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

}

/// Хранилище в памяти — для тестов и для случая, когда Hive
/// недоступен (например, при ошибке инициализации на устройстве).
class InMemoryCalculationStore implements CalculationStore {
  final Map<String, CalculationRecord> _records = {};

  @override
  Future<void> save(CalculationRecord record) async => _records[record.id] = record;

  @override
  Future<void> delete(String id) async => _records.remove(id);

  @override
  List<CalculationRecord> readAll() =>
      _records.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

}
