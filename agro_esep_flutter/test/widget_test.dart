import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/data/local/calculation_store.dart';
import 'package:agro_esep/data/normatives/normatives.dart';
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

Future<void> _pumpApp(WidgetTester tester, Normatives normatives) async {
  await tester.pumpWidget(AgroEsepApp(
    calculatorCubit: CalculatorCubit(
      normatives: normatives,
      solver: const _StubSolver(),
      store: InMemoryCalculationStore(),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  late Normatives normatives;

  setUpAll(() => normatives = buildTestNormatives());

  testWidgets('приложение открывается на главной и показывает CTA расчёта',
      (tester) async {
    await _pumpApp(tester, normatives);

    expect(find.text('Институт математики НАН КР'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Рассчитать оптимальное решение'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Рассчитать оптимальное решение'), findsOneWidget);
  });

  testWidgets('нижняя навигация переключает разделы', (tester) async {
    await _pumpApp(tester, normatives);

    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Мои расчёты'), findsWidgets);
    expect(find.text('Пока нет сохранённых расчётов'), findsOneWidget);
  });

  testWidgets('контакты открываются с главной', (tester) async {
    await _pumpApp(tester, normatives);

    await tester.scrollUntilVisible(
      find.text('Контакты института'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Контакты института'));
    await tester.pumpAndSettle();

    expect(find.text('Адрес'), findsOneWidget);
    expect(find.text('+996 312 64-27-08'), findsOneWidget);
  });

  testWidgets('мастер проходит все пять шагов до экрана проверки данных',
      (tester) async {
    await _pumpApp(tester, normatives);

    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Начать расчёт'));
    await tester.pumpAndSettle();

    // шаг 1 — тип хозяйства: кнопка неактивна, пока ничего не выбрано
    expect(find.text('ШАГ 1 ИЗ 5'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.tap(find.text('Крестьянское (фермерское)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();

    // шаг 2 — угодья
    expect(find.text('ШАГ 2 ИЗ 5'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '120');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();

    // шаг 3 — план производства
    expect(find.text('ШАГ 3 ИЗ 5'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();

    // шаг 4 — породы
    expect(find.text('ШАГ 4 ИЗ 5'), findsOneWidget);
    await tester.tap(find.text('Алатауская'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();

    // шаг 5 — сводка перед расчётом
    expect(find.text('ШАГ 5 ИЗ 5'), findsOneWidget);
    expect(find.text('Рассчитать оптимальный вариант'), findsOneWidget);
    expect(find.text('120 га'), findsOneWidget);
    expect(find.text('100 т'), findsOneWidget);
  });

  testWidgets('нереалистичный план вызывает предупреждение, но не блокирует',
      (tester) async {
    await _pumpApp(tester, normatives);

    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Начать расчёт'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Крестьянское (фермерское)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '10');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();

    // 3000 т молока с 10 га — заведомо перепутаны литры и тонны
    await tester.enterText(find.byType(TextField).first, '3000');
    await tester.pumpAndSettle();

    expect(find.textContaining('Возможно, указаны литры вместо тонн?'), findsOneWidget);
    // предупреждение не блокирует — кнопка остаётся активной
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
}
