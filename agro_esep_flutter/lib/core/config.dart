/// Адрес сервиса расчёта. Переопределяется при сборке:
///   flutter run --dart-define=SOLVER_BASE_URL=http://10.0.2.2:8000
///
/// По умолчанию — локальный uvicorn для разработки; на релизной сборке
/// подставляется URL развёрнутого сервиса.
abstract final class AppConfig {
  static const solverBaseUrl = String.fromEnvironment(
    'SOLVER_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
