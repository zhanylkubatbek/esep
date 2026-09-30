import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/farm_type.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';
import '../widgets/wizard_scaffold.dart';
import '../../../../core/l10n/app_localizations.dart';

class StepFarmTypeScreen extends StatelessWidget {
  const StepFarmTypeScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      bloc: cubit,
      builder: (context, state) => WizardScaffold(
        step: 1,
        totalSteps: 5,
        question: L.of(context).stepFarmTypeQuestion,
        hint: L.of(context).stepFarmTypeHint,
        actionLabel: L.of(context).ctaNext,
        onAction: state.farmType == null ? null : () => context.go('/calculator/land'),
        child: Column(
          children: [
            for (final type in FarmType.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FarmTypeTile(
                  type: type,
                  selected: state.farmType == type,
                  onTap: () => cubit.setFarmType(type),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FarmTypeTile extends StatelessWidget {
  const _FarmTypeTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final FarmType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.heading : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.heading : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.title(L.of(context)),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.heading,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description(L.of(context)),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
