import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';
import '../widgets/wizard_scaffold.dart';
import '../../../../core/formatting.dart';
import '../../../../core/l10n/app_localizations.dart';

class StepReviewScreen extends StatelessWidget {
  const StepReviewScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      bloc: cubit,
      builder: (context, state) {
        final n = cubit.normatives;
        final names = n.namesFor(L.of(context).localeName);

        return WizardScaffold(
          appBarTitle: L.of(context).stepReviewTitle,
          step: 5,
          totalSteps: 5,
          question: L.of(context).stepReviewAllCorrect,
          hint: L.of(context).stepReviewHint,
          actionLabel: L.of(context).ctaSolve,
          actionSubtitle: L.of(context).ctaSolveSubtitle,
          onAction: () {
            cubit.runCalculation();
            context.go('/calculator/solving');
          },
          child: Column(
            children: [
              _ReviewBlock(
                title: L.of(context).blockFarm,
                onEdit: () => context.go('/calculator/type'),
                rows: [(label: L.of(context).blockFarmType, value: state.farmType?.title(L.of(context)) ?? '—')],
              ),
              _ReviewBlock(
                title: L.of(context).blockLand,
                onEdit: () => context.go('/calculator/land'),
                rows: [
                  for (final land in n.lands)
                    if (state.landAreas[land.id] != null)
                      (
                        label: names.land(land.id),
                        value: '${Num.area(state.landAreas[land.id]!)} ${L.of(context).unitHa}',
                      ),
                ],
              ),
              _ReviewBlock(
                title: L.of(context).blockPlan,
                onEdit: () => context.go('/calculator/plan'),
                rows: [
                  for (final product in n.products)
                    if (state.productionPlan[product.id] != null)
                      (
                        label: names.product(product.id),
                        value: '${Num.area(state.productionPlan[product.id]!)} ${L.of(context).unitTons}',
                      ),
                ],
              ),
              _ReviewBlock(
                title: L.of(context).blockBreeds,
                onEdit: () => context.go('/calculator/breeds'),
                rows: [
                  for (final entry in n.breedsById.entries)
                    if (state.selectedBreedIds.contains(entry.key))
                      (label: names.breed(entry.key), value: L.of(context).yes),
                ],
              ),
              if (n.isDemo)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF3E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF0D9BC)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          L.of(context).demoNormativesWarning(n.version),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.warning,
                                height: 1.45,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

}

typedef _ReviewRow = ({String label, String value});

class _ReviewBlock extends StatelessWidget {
  const _ReviewBlock({
    required this.title,
    required this.rows,
    required this.onEdit,
  });

  final String title;
  final List<_ReviewRow> rows;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  GestureDetector(
                    onTap: onEdit,
                    child: Text(
                      L.of(context).stepReviewEdit,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.accent,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          row.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        row.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.heading,
                              fontFeatures: const [FontFeature.tabularFigures()],
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
