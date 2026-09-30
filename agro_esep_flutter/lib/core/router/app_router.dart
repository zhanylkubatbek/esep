import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calculator/presentation/calculator_intro_screen.dart';
import '../../features/calculator/presentation/cubit/calculator_cubit.dart';
import '../../features/calculator/presentation/result/explain_screen.dart';
import '../../features/calculator/presentation/result/failed_screen.dart';
import '../../features/calculator/presentation/result/infeasible_screen.dart';
import '../../features/calculator/presentation/result/result_screen.dart';
import '../../features/calculator/presentation/result/solving_screen.dart';
import '../../features/calculator/presentation/steps/step_breeds.dart';
import '../../features/calculator/presentation/steps/step_farm_type.dart';
import '../../features/calculator/presentation/steps/step_land.dart';
import '../../features/calculator/presentation/steps/step_plan.dart';
import '../../features/calculator/presentation/steps/step_review.dart';
import '../../data/normatives/normatives_repository.dart';
import '../../features/admin/presentation/normatives_import_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/info/presentation/about_screen.dart';
import '../../features/info/presentation/contacts_screen.dart';
import '../../features/info/presentation/home_screen.dart';
import '../../features/info/presentation/model_screen.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

GoRouter buildRouter(
  CalculatorCubit calculator, {
  NormativesRepository normativesRepository = const NormativesRepository(),
  NormativesSource normativesSource = NormativesSource.bundled,
}) =>
    GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => _ShellScaffold(shell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/model', builder: (_, _) => const ModelScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/about', builder: (_, _) => const AboutScreen())],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/calculator',
                  builder: (_, _) => const CalculatorIntroScreen(),
                  routes: [
                    GoRoute(
                      path: 'type',
                      builder: (_, _) => StepFarmTypeScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'land',
                      builder: (_, _) => StepLandScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'plan',
                      builder: (_, _) => StepPlanScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'breeds',
                      builder: (_, _) => StepBreedsScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'review',
                      builder: (_, _) => StepReviewScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'solving',
                      builder: (_, _) => SolvingScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'result',
                      builder: (_, _) => ResultScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'explain',
                      builder: (_, _) => ExplainScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'infeasible',
                      builder: (_, _) => InfeasibleScreen(cubit: calculator),
                    ),
                    GoRoute(
                      path: 'failed',
                      builder: (_, _) => FailedScreen(cubit: calculator),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  builder: (_, _) => HistoryScreen(cubit: calculator),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/contacts',
          builder: (_, _) =>
              ContactsScreen(normativesVersion: calculator.normatives.version),
        ),
        // Режим администратора: открывается длинным нажатием на строку
        // с версией нормативов на экране контактов. Отдельной кнопки нет —
        // обычному пользователю этот экран не нужен.
        GoRoute(
          path: '/admin/normatives',
          builder: (_, _) => NormativesImportScreen(
            repository: normativesRepository,
            current: calculator.normatives,
            currentSource: normativesSource,
          ),
        ),
      ],
    );

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      // Подписи вкладок намеренно короткие и в одно слово: на узком
      // экране пять подписей делят ширину поровну, и «Мои расчёты»
      // переносилось на две строки. «История» заодно не путается
      // с соседней вкладкой «Расчёт».
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        // Крупный системный шрифт (а его часто включают) не должен
        // ломать панель: подписи и так короткие, но запас нужен.
        maxScaleFactor: 1.2,
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: AppColors.heroEnd),
              label: L.of(context).navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.functions_outlined),
              selectedIcon: const Icon(Icons.functions, color: AppColors.heroEnd),
              label: L.of(context).navModel,
            ),
            NavigationDestination(
              icon: const Icon(Icons.info_outline),
              selectedIcon: const Icon(Icons.info, color: AppColors.heroEnd),
              label: L.of(context).navAbout,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calculate_outlined),
              selectedIcon: const Icon(Icons.calculate, color: AppColors.heroEnd),
              label: L.of(context).navCalculator,
            ),
            NavigationDestination(
              icon: const Icon(Icons.folder_outlined),
              selectedIcon: const Icon(Icons.folder, color: AppColors.heroEnd),
              label: L.of(context).navHistory,
            ),
          ],
        ),
      ),
    );
  }
}
