import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../models/farm_model.dart';

/// Клиент решателя. Весь доступ к расчёту идёт через этот интерфейс —
/// если позже появится встроенный офлайн-решатель, экраны и модель
/// данных не меняются, подменяется только реализация.
abstract interface class FarmSolver {
  Future<OptimizationResult> solve(OptimizationInput input);
}

/// Что именно пошло не так — экран должен говорить пользователю
/// разное при «нет связи» и «сервис не ответил».
/// Почему расчёт не удался.
///
/// [noConnection] и [serviceUnreachable] специально разделены: с точки
/// зрения кода это одно и то же исключение сокета, но для пользователя
/// это разные вещи. «Нет интернета» при работающем интернете — ложь,
/// из-за которой человек будет проверять свой телефон вместо того,
/// чтобы сообщить о неполадке.
enum SolverFailureKind {
  /// На устройстве нет сети — проверено средствами системы.
  noConnection,

  /// Сеть есть, но сервис расчёта не отвечает: не развёрнут,
  /// указан неверный адрес или временно недоступен.
  serviceUnreachable,

  timeout,
  serverError,
}

class SolverException implements Exception {
  const SolverException(this.kind, [this.details]);

  final SolverFailureKind kind;
  final String? details;

  /// Стоит ли повторять отправку автоматически при появлении сети.
  bool get isRetryable =>
      kind == SolverFailureKind.noConnection ||
      kind == SolverFailureKind.serviceUnreachable;

  @override
  String toString() => 'SolverException($kind${details == null ? '' : ': $details'})';
}

class RemoteFarmSolver implements FarmSolver {
  RemoteFarmSolver({
    required this.baseUrl,
    http.Client? client,
    Future<bool> Function()? hasNetwork,
  })  : _client = client ?? http.Client(),
        _hasNetwork = hasNetwork ?? _deviceHasNetwork;

  final String baseUrl;
  final http.Client _client;

  /// Проверка наличия сети на устройстве. Нужна, чтобы отличить
  /// «интернета нет» от «сервис недоступен» — оба случая приходят
  /// в код одинаковым исключением сокета.
  final Future<bool> Function() _hasNetwork;

  static Future<bool> _deviceHasNetwork() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Бесплатный тариф Render засыпает без обращений и просыпается
  /// до минуты — таймаут учитывает это, а экран показывает объяснение,
  /// а не пустой спиннер.
  static const _timeout = Duration(seconds: 90);

  @override
  Future<OptimizationResult> solve(OptimizationInput input) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/v1/solve'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(input.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw SolverException(
          SolverFailureKind.serverError,
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return OptimizationResult.fromJson(decoded);
    } on SocketException catch (e) {
      throw SolverException(await _connectionFailureKind(), e.message);
    } on TimeoutException {
      throw const SolverException(SolverFailureKind.timeout);
    } on http.ClientException catch (e) {
      throw SolverException(await _connectionFailureKind(), e.message);
    }
  }

  /// Соединение не установилось. Спрашиваем систему, есть ли вообще сеть:
  /// если есть — виноват не телефон пользователя, а недоступный сервис,
  /// и сказать об этом надо прямо.
  Future<SolverFailureKind> _connectionFailureKind() async {
    try {
      return await _hasNetwork()
          ? SolverFailureKind.serviceUnreachable
          : SolverFailureKind.noConnection;
    } catch (_) {
      // проверка сети сама не сработала — не выдумываем причину
      return SolverFailureKind.serviceUnreachable;
    }
  }
}
