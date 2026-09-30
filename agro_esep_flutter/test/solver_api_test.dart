import 'dart:io';

import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/data/remote/solver_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const _input = OptimizationInput(
  lands: [LandCategory(id: 'irrigated', name: 'Орошаемая', areaHa: 10)],
  crops: [],
  breedProducts: [],
  productionPlan: {'milk': 10},
  normativesVersion: 'test-1.0',
);

/// Клиент, который всегда падает так, будто соединение не установилось.
class _FailingClient extends http.BaseClient {
  _FailingClient(this.error);

  final Object error;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => throw error;
}

RemoteFarmSolver _solver({required Object error, required bool network}) =>
    RemoteFarmSolver(
      baseUrl: 'http://example.invalid:8000',
      client: _FailingClient(error),
      hasNetwork: () async => network,
    );

void main() {
  group('различение «нет интернета» и «сервис недоступен»', () {
    test('сеть есть, сервис не отвечает — говорим про сервис, не про интернет',
        () async {
      final solver = _solver(
        error: const SocketException('Connection refused'),
        network: true,
      );

      final failure = await solver.solve(_input).then<SolverException?>(
            (_) => null,
            onError: (Object e) => e as SolverException,
          );

      // главное: причина отделена от «нет интернета» — экран покажет
      // разный текст, а на каком языке, решает локаль
      expect(failure!.kind, SolverFailureKind.serviceUnreachable);
      expect(failure.kind, isNot(SolverFailureKind.noConnection));
    });

    test('сети на устройстве нет — сообщаем именно об этом', () async {
      final solver = _solver(
        error: const SocketException('Network is unreachable'),
        network: false,
      );

      final failure = await solver.solve(_input).then<SolverException?>(
            (_) => null,
            onError: (Object e) => e as SolverException,
          );

      expect(failure!.kind, SolverFailureKind.noConnection);
    });

    test('ошибка http-клиента тоже проходит через проверку сети', () async {
      final solver = _solver(
        error: http.ClientException('Connection closed'),
        network: true,
      );

      final failure = await solver.solve(_input).then<SolverException?>(
            (_) => null,
            onError: (Object e) => e as SolverException,
          );

      expect(failure!.kind, SolverFailureKind.serviceUnreachable);
    });

    test('если сама проверка сети падает — не выдумываем «нет интернета»',
        () async {
      final solver = RemoteFarmSolver(
        baseUrl: 'http://example.invalid:8000',
        client: _FailingClient(const SocketException('refused')),
        hasNetwork: () async => throw StateError('плагин недоступен'),
      );

      final failure = await solver.solve(_input).then<SolverException?>(
            (_) => null,
            onError: (Object e) => e as SolverException,
          );

      expect(failure!.kind, SolverFailureKind.serviceUnreachable);
    });
  });

  group('повторная отправка', () {
    test('оба вида сбоя связи отправляются повторно', () {
      expect(
        const SolverException(SolverFailureKind.noConnection).isRetryable,
        isTrue,
      );
      expect(
        const SolverException(SolverFailureKind.serviceUnreachable).isRetryable,
        isTrue,
      );
    });

    test('ошибка сервера автоматически не повторяется', () {
      expect(
        const SolverException(SolverFailureKind.serverError).isRetryable,
        isFalse,
      );
    });
  });
}
