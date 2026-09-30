import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Общий каркас шага мастера: прогресс «шаг N из 5», заголовок-вопрос,
/// содержимое и закреплённая внизу кнопка «Дальше».
class WizardScaffold extends StatelessWidget {
  const WizardScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.question,
    required this.hint,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.actionSubtitle,
    this.footnote,
    this.appBarTitle,
  });

  final int step;
  final int totalSteps;
  final String question;
  final String hint;
  final Widget child;
  final String actionLabel;
  final String? actionSubtitle;
  final VoidCallback? onAction;
  final String? footnote;
  final String? appBarTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle ?? L.of(context).wizardTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var i = 1; i <= totalSteps; i++) ...[
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= step ? AppColors.accent : AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (i < totalSteps) const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  L.of(context).wizardStep(step, totalSteps),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  question,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.heading,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  hint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [child],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: onAction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(actionLabel),
                    if (actionSubtitle != null)
                      Text(
                        actionSubtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              if (footnote != null) ...[
                const SizedBox(height: 10),
                Text(
                  footnote!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
