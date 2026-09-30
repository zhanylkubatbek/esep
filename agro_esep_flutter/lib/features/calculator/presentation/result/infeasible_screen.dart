import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/calculator_cubit.dart';
import '../../../../core/formatting.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Вместо «решение не найдено» — чего именно не хватает и сколько.
///
/// Показаны только те выходы, которые модель действительно считает:
/// уменьшить план или добавить земли. Варианта «докупить корма» здесь
/// нет — в модели института (1.3) нет переменной закупки кормов,
/// и предлагать её как готовое решение было бы обещанием того,
/// что решатель не рассчитывал.
class InfeasibleScreen extends StatelessWidget {
  const InfeasibleScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    final missing = cubit.state.result?.landHaMissing ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).wizardTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/calculator/review'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFDECE9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.priority_high, color: AppColors.accent),
          ),
          const SizedBox(height: 20),
          Text(
            L.of(context).infeasibleTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            L.of(context).infeasibleFullDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          if (missing > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.accent, width: 4),
                  top: BorderSide(color: AppColors.divider),
                  right: BorderSide(color: AppColors.divider),
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+${Num.withUnit(Num.area(missing), L.of(context).unitHa)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.heading,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    L.of(context).infeasibleMissingLand,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.go('/calculator/plan'),
            child: Text(L.of(context).ctaReducePlan),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/calculator/land'),
            child: Text(L.of(context).ctaChangeLand),
          ),
        ],
      ),
    );
  }

}
