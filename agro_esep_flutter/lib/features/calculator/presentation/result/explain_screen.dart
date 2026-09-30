import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/farm_model.dart';
import '../cubit/calculator_cubit.dart';
import '../../../../core/formatting.dart';
import '../../../../core/l10n/app_localizations.dart';

/// «Как это посчитано»: каждое ограничение модели переведено в шкалу,
/// под шкалой подписана формула. Экран убеждает и агронома,
/// и научного руководителя (экран 09 макетов).
class ExplainScreen extends StatelessWidget {
  const ExplainScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    final result = cubit.state.result;
    if (result == null || result.status != SolveStatus.optimal) {
      return Scaffold(body: Center(child: Text(L.of(context).noResult)));
    }

    final n = cubit.normatives;
    final names = n.namesFor(L.of(context).localeName);
    final usedHa = result.cropArea.fold<double>(0, (sum, a) => sum + a.areaHa);
    final totalHa = cubit.state.totalLandHa;

    // Проверка (1.4): выход продукции против плана.
    final producedByProduct = <String, double>{};
    for (final animal in result.livestock) {
      final bp = n.breedProducts.firstWhere(
        (e) => e.breedId == animal.breedId && e.productId == animal.productId,
      );
      producedByProduct.update(
        animal.productId,
        (v) => v + bp.yieldPerHead * animal.heads,
        ifAbsent: () => bp.yieldPerHead * animal.heads,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).explainTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/calculator/result'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ExplainCard(
            title: L.of(context).explainLandUse,
            value: '${Num.area(usedHa)} / ${Num.area(totalHa)} ${L.of(context).unitHa}',
            ratio: totalHa == 0 ? 0 : usedHa / totalHa,
            barColor: AppColors.success,
            description: L.of(context).explainLandUsed(
                ((usedHa / (totalHa == 0 ? 1 : totalHa)) * 100).round()),
            formula: L.of(context).explainFormulaLand,
          ),
          for (final entry in producedByProduct.entries)
            _ExplainCard(
              title: L.of(context).explainPlanFor(names.product(entry.key)),
              value: entry.value >= (cubit.state.productionPlan[entry.key] ?? 0)
                  ? L.of(context).explainFulfilled
                  : L.of(context).explainNotFulfilled,
              ratio: 1,
              barColor: AppColors.success,
              description: L.of(context).explainPlanText(
                  Num.area(entry.value),
                  Num.area(cubit.state.productionPlan[entry.key] ?? 0)),
              formula: L.of(context).explainFormulaPlan,
            ),
          _ExplainCard(
            title: L.of(context).explainFeedBalance,
            value: L.of(context).explainObserved,
            ratio: 1,
            barColor: AppColors.success,
            description: L.of(context).explainFeedText,
            formula: L.of(context).explainFormulaFeed,
          ),
          _ExplainCard(
            title: L.of(context).explainFeedPurchaseTitle,
            value: result.feedPurchase.isEmpty
                ? L.of(context).explainFeedPurchaseNone
                : L.of(context).explainFeedPurchaseSome(
                    Num.area(result.feedPurchase
                        .fold<double>(0, (sum, p) => sum + p.tons)),
                    Num.integer(result.purchaseCost),
                  ),
            ratio: 1,
            barColor: result.feedPurchase.isEmpty
                ? AppColors.success
                : AppColors.accent,
            description: result.feedPurchase.isEmpty
                ? L.of(context).explainFeedPurchaseTextNone
                : L.of(context).explainFeedPurchaseTextSome,
            formula: L.of(context).explainFormulaPurchase,
          ),
          _ExplainCard(
            title: L.of(context).explainCostStructure,
            value:
                '${Num.integer(result.totalCost ?? 0)} ${L.of(context).unitSom}',
            ratio: 1,
            barColor: AppColors.heading,
            description: L.of(context).explainCostText,
            formula: L.of(context).explainFormulaCost,
          ),
        ],
      ),
    );
  }

}

class _ExplainCard extends StatelessWidget {
  const _ExplainCard({
    required this.title,
    required this.value,
    required this.ratio,
    required this.barColor,
    required this.description,
    required this.formula,
  });

  final String title;
  final String value;
  final double ratio;
  final Color barColor;
  final String description;
  final String formula;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.heading,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.heading,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    formula,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
