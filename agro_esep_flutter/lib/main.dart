import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/local/calculation_store.dart';
import 'data/normatives/normatives_repository.dart';
import 'features/calculator/presentation/cubit/calculator_cubit.dart';
import 'features/settings/data/hive_settings_repository.dart';
import 'features/settings/domain/settings_repository.dart';
import 'features/settings/presentation/cubit/locale_cubit.dart';
import 'solver/local_farm_solver.dart';

/// Точка сборки (composition root): здесь создаются реализации
/// data-слоя и передаются кубитам. Ниже по дереву никто не знает,
/// какая именно реализация используется.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const repository = NormativesRepository();
  final loaded = await repository.load();

  // Если локальное хранилище почему-то не открылось, приложение всё равно
  // должно работать — расчёты просто не сохранятся между запусками.
  CalculationStore store;
  try {
    store = await HiveCalculationStore.open();
  } catch (_) {
    store = InMemoryCalculationStore();
  }

  SettingsRepository settings;
  try {
    settings = await HiveSettingsRepository.open();
  } catch (_) {
    settings = InMemorySettingsRepository();
  }

  runApp(AgroEsepApp(
    calculatorCubit: CalculatorCubit(
      normatives: loaded.normatives,
      // Расчёт выполняется на самом устройстве: интернет не нужен
      // ни для расчёта, ни для просмотра сохранённых решений.
      solver: const LocalFarmSolver(),
      store: store,
    ),
    localeCubit: LocaleCubit(settings),
    normativesRepository: repository,
    normativesSource: loaded.source,
  ));
}

class AgroEsepApp extends StatefulWidget {
  AgroEsepApp({
    super.key,
    required this.calculatorCubit,
    this.normativesRepository = const NormativesRepository(),
    this.normativesSource = NormativesSource.bundled,
    LocaleCubit? localeCubit,
  }) : localeCubit = localeCubit ?? LocaleCubit(InMemorySettingsRepository());

  final CalculatorCubit calculatorCubit;

  final NormativesRepository normativesRepository;
  final NormativesSource normativesSource;
  final LocaleCubit localeCubit;

  @override
  State<AgroEsepApp> createState() => _AgroEsepAppState();
}

class _AgroEsepAppState extends State<AgroEsepApp> {
  late final _router = buildRouter(
    widget.calculatorCubit,
    normativesRepository: widget.normativesRepository,
    normativesSource: widget.normativesSource,
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.localeCubit),
        BlocProvider.value(value: widget.calculatorCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            onGenerateTitle: (context) => L.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _router,
            locale: locale,
            localizationsDelegates: const [
              L.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L.supportedLocales,
          );
        },
      ),
    );
  }
}
