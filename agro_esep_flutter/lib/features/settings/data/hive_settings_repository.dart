import 'package:hive_flutter/hive_flutter.dart';

import '../domain/settings_repository.dart';

/// Настройки в Hive-боксе `settings` — переживают перезапуск приложения.
class HiveSettingsRepository implements SettingsRepository {
  HiveSettingsRepository._(this._box);

  static const _boxName = 'settings';
  static const _localeKey = 'locale';

  final Box<dynamic> _box;

  static Future<HiveSettingsRepository> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>(_boxName);
    return HiveSettingsRepository._(box);
  }

  @override
  String? readLocaleCode() => _box.get(_localeKey) as String?;

  @override
  Future<void> saveLocaleCode(String code) => _box.put(_localeKey, code);
}
