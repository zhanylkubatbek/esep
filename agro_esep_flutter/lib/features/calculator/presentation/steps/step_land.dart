import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';
import '../widgets/labeled_number_field.dart';
import '../widgets/wizard_scaffold.dart';
import '../../../../core/formatting.dart';
import '../../../../core/l10n/app_localizations.dart';

class StepLandScreen extends StatelessWidget {
  const StepLandScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      bloc: cubit,
      builder: (context, state) {
        final names = cubit.normatives.namesFor(L.of(context).localeName);
        return WizardScaffold(
          step: 2,
        totalSteps: 5,
        question: L.of(context).stepLandQuestion,
        hint: L.of(context).stepLandHint,
        actionLabel: L.of(context).ctaNext,
        onAction: state.hasLand ? () => context.go('/calculator/plan') : null,
        child: Column(
          children: [
            for (final land in cubit.normatives.lands)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LabeledNumberField(
                  label: names.land(land.id),
                  unit: L.of(context).unitHa,
                  initialValue: state.landAreas[land.id],
                  onChanged: (value) => cubit.setLandArea(land.id, value),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                state.hasLand
                    ? '${L.of(context).stepLandTotal(Num.area(state.totalLandHa))}\n'
                        '${L.of(context).stepLandPastureNote}'
                    : L.of(context).stepLandEmptyHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
              ),
            ),
            ],
          ),
        );
      },
    );
  }
}
