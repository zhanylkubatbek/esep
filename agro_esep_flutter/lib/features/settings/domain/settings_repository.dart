/// Контракт хранилища настроек пользователя.
///
/// Domain-слой ничего не знает о Hive: presentation работает только
/// с этим интерфейсом, конкретная реализация подставляется в main.dart.
abstract interface class SettingsRepository {
  /// Код сохранённого языка (`ky`/`ru`) или null, если выбора ещё не было.
  String? readLocaleCode();

  Future<void> saveLocaleCode(String code);
}

/// Реализация «в памяти» — для тестов и как запасной вариант,
/// если локальное хранилище не открылось.
class InMemorySettingsRepository implements SettingsRepository {
  String? _code;

  @override
  String? readLocaleCode() => _code;

  @override
  Future<void> saveLocaleCode(String code) async => _code = code;
}
