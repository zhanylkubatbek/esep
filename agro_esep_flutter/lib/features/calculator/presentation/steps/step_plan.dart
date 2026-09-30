import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatting.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';
import '../widgets/labeled_number_field.dart';
import '../widgets/wizard_scaffold.dart';
import '../../../../core/l10n/app_localizations.dart';

class StepPlanScreen extends StatelessWidget {
  const StepPlanScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      bloc: cubit,
      builder: (context, state) {
        final names = cubit.normatives.namesFor(L.of(context).localeName);
        final warnings = {
          for (final w in cubit.plausibilityWarnings)
            w.productId: L.of(context).plausibilityTooMuch(
              Num.area(w.landHa),
              Num.area(w.maxReasonableT),
            ),
        };

        return WizardScaffold(
          step: 3,
          totalSteps: 5,
          question: L.of(context).stepPlanQuestion,
          hint: L.of(context).stepPlanHint,
          actionLabel: L.of(context).ctaNext,
          onAction: state.hasPlan ? () => context.go('/calculator/breeds') : null,
          footnote: warnings.isEmpty
              ? null
              : L.of(context).stepPlanWarningFootnote,
          child: Column(
            children: [
              for (final product in cubit.normatives.products)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LabeledNumberField(
                    label: names.product(product.id),
                    unit: names.unit(product.id),
                    initialValue: state.productionPlan[product.id],
                    warning: warnings[product.id],
                    onChanged: (value) => cubit.setProductionPlan(product.id, value),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
