import 'package:agro_esep/data/local/calculation_store.dart';
import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/data/normatives/normatives.dart';
import 'package:agro_esep/data/remote/solver_api.dart';
import 'package:agro_esep/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:agro_esep/data/normatives/normatives_repository.dart';
import 'package:agro_esep/features/settings/domain/settings_repository.dart';
import 'package:agro_esep/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:agro_esep/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubSolver implements FarmSolver {
  const _StubSolver();

  @override
  Future<OptimizationResult> solve(OptimizationInput input) async =>
      const OptimizationResult(status: SolveStatus.optimal, solverVersion: 'stub');
}

/// Проходит мастер на кыргызском и смотрит, что на экранах нет
/// русского текста: и подписи интерфейса, и названия из нормативной
/// базы должны переключаться вместе с языком.
void main() {
  late Normatives normatives;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    normatives = await Normatives.loadFromAssets();
  });

  Future<void> pumpKy(WidgetTester tester) async {
    final settings = InMemorySettingsRepository();
    await settings.saveLocaleCode('ky');

    await tester.pumpWidget(AgroEsepApp(
      calculatorCubit: CalculatorCubit(
        normatives: normatives,
        solver: const _StubSolver(),
        store: InMemoryCalculationStore(),
      ),
      localeCubit: LocaleCubit(settings),
      normativesRepository: const NormativesRepository(),
    ));
    await tester.pumpAndSettle();
  }

  /// Доводит мастер до шага «сколько земли».
  Future<void> openLandStep(WidgetTester tester) async {
    await pumpKy(tester);

    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Эсептөөнү баштоо'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дыйкан (фермер) чарбасы'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Кийинки'));
    await tester.pumpAndSettle();
  }

  testWidgets('угодья названы по-кыргызски', (tester) async {
    await openLandStep(tester);

    expect(find.text('Жериңиз канча?'), findsOneWidget);
    expect(find.text('Сугат айдоо жери'), findsOneWidget);
    expect(find.text('Жайыттар'), findsOneWidget);
    expect(find.text('Орошаемая пашня'), findsNothing);
    expect(find.text('Пастбища'), findsNothing);
  });

  testWidgets('продукция и её единицы названы по-кыргызски', (tester) async {
    await openLandStep(tester);

    await tester.enterText(find.byType(TextField).first, '120');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Кийинки'));
    await tester.pumpAndSettle();

    expect(find.text('Сүт'), findsOneWidget);
    expect(find.text('Эт (кошумча салмак)'), findsOneWidget);
    expect(find.text('т/жыл'), findsWidgets);
    expect(find.text('Молоко'), findsNothing);
    expect(find.text('т/год'), findsNothing);
  });

  testWidgets('породы названы по-кыргызски', (tester) async {
    await openLandStep(tester);

    await tester.enterText(find.byType(TextField).first, '120');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Кийинки'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Кийинки'));
    await tester.pumpAndSettle();

    expect(find.text('Алатоо тукуму'), findsOneWidget);
    expect(find.text('Кыргыз эт тукуму'), findsOneWidget);
    expect(find.text('Алатауская'), findsNothing);
  });

  testWidgets('адрес института записан по-кыргызски', (tester) async {
    await pumpKy(tester);

    await tester.scrollUntilVisible(
      find.text('Институттун байланыштары'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Институттун байланыштары'));
    await tester.pumpAndSettle();

    expect(find.text('720071, Бишкек ш., Чүй пр., 265а'), findsOneWidget);
    expect(find.text('720071, г. Бишкек, просп. Чуй, 265а'), findsNothing);
  });
}
