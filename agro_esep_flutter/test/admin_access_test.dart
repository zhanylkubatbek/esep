import 'package:agro_esep/data/local/calculation_store.dart';
import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/data/remote/solver_api.dart';
import 'package:agro_esep/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:agro_esep/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_normatives.dart';

class _StubSolver implements FarmSolver {
  const _StubSolver();

  @override
  Future<OptimizationResult> solve(OptimizationInput input) async =>
      const OptimizationResult(status: SolveStatus.optimal, solverVersion: 'stub');
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(AgroEsepApp(
    calculatorCubit: CalculatorCubit(
      normatives: buildTestNormatives(),
      solver: const _StubSolver(),
      store: InMemoryCalculationStore(),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _openContacts(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Контакты института'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text('Контакты института'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('версия нормативов видна на экране контактов', (tester) async {
    await _pumpApp(tester);
    await _openContacts(tester);

    expect(find.text('Нормативная база: test-1.0'), findsOneWidget);
  });

  testWidgets('обычное нажатие на версию не открывает режим администратора',
      (tester) async {
    await _pumpApp(tester);
    await _openContacts(tester);

    await tester.tap(find.text('Нормативная база: test-1.0'));
    await tester.pumpAndSettle();

    expect(find.text('Нормативная база'), findsNothing);
    expect(find.text('Загрузить файл Excel'), findsNothing);
  });

  testWidgets('длинное нажатие открывает режим администратора', (tester) async {
    await _pumpApp(tester);
    await _openContacts(tester);

    await tester.longPress(find.text('Нормативная база: test-1.0'));
    await tester.pumpAndSettle();

    expect(find.text('ДЕЙСТВУЮЩАЯ БАЗА'), findsOneWidget);
    expect(find.text('Загрузить файл Excel'), findsOneWidget);
    // видно, на какой базе сейчас считает приложение
    expect(find.text('test-1.0'), findsOneWidget);
    expect(find.text('встроена в приложение'), findsOneWidget);
  });

  testWidgets('в режиме администратора описан формат файла', (tester) async {
    await _pumpApp(tester);
    await _openContacts(tester);
    await tester.longPress(find.text('Нормативная база: test-1.0'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('ФОРМАТ ФАЙЛА'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('ФОРМАТ ФАЙЛА'), findsOneWidget);
    expect(find.textContaining('CSV из Windows-версии Excel портит кириллицу'),
        findsOneWidget);
  });

  testWidgets('демонстрационная база помечена предупреждением', (tester) async {
    await _pumpApp(tester);
    await _openContacts(tester);
    await tester.longPress(find.text('Нормативная база: test-1.0'));
    await tester.pumpAndSettle();

    // фикстура помечена is_demo: true
    expect(
      find.textContaining('нельзя предъявлять хозяйствам'),
      findsOneWidget,
    );
  });
}
