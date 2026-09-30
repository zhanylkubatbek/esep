import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/farm_model.dart';
import '../../domain/farm_type.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Экран ожидания. Этапы показаны словами — ожидание становится
/// объяснимым, а не пустым (экран 07 макетов). Сервис на бесплатном
/// тарифе может просыпаться до минуты, и об этом честно сказано.
///
/// Навигация по завершении — через BlocListener: он реагирует
/// на смену состояния, не перестраивая интерфейс.
class SolvingScreen extends StatelessWidget {
  const SolvingScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalculatorCubit, CalculatorState>(
      bloc: cubit,
      listener: (context, state) {
        if (state.phase == CalculationPhase.done) {
          final isInfeasible = state.result?.status == SolveStatus.infeasible;
          context
              .go(isInfeasible ? '/calculator/infeasible' : '/calculator/result');
        } else if (state.phase == CalculationPhase.failed) {
          context.go('/calculator/failed');
        }
      },
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).wizardTitleShort), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: AppColors.accent,
                  backgroundColor: AppColors.divider,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                L.of(context).solvingTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.heading,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                L.of(context).solvingDescriptionFull,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 28),
              _Stage(label: L.of(context).solvingStageChecked, done: true),
              _Stage(label: L.of(context).solvingStageNormatives, done: true),
              _Stage(label: L.of(context).solvingStageOptimizing, done: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: done ? AppColors.success : AppColors.accent,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: done ? AppColors.textPrimary : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
