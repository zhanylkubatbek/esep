import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/project_content.dart';
import '../../../core/l10n/app_localizations.dart';

/// Экран «Как работает калькулятор» — первый шаг перед мастером ввода
/// (экран 01 из макетов). Сам мастер добавляется следующим этапом.
class CalculatorIntroScreen extends StatelessWidget {
  const CalculatorIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = ProjectContent.of(context).calculatorSteps;

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).onlineCalculation)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            L.of(context).howItWorksTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            L.of(context).howItWorksSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.heading,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.heading,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i].description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () => context.go('/calculator/type'),
                child: Text(L.of(context).ctaStart),
              ),
              const SizedBox(height: 12),
              Text(
                ProjectContent.of(context).disclaimer,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
