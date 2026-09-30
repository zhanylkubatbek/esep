import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/remote/solver_api.dart';
import '../cubit/calculator_cubit.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Расчёт не удалось выполнить. Введённые данные не теряются —
/// пользователь возвращается к сводке и повторяет попытку.
class FailedScreen extends StatelessWidget {
  const FailedScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    final failure = cubit.state.failure;
    final kind = failure?.kind;
    final isOffline = kind == SolverFailureKind.noConnection;

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
              color: const Color(0xFFFDF3E7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOffline ? Icons.wifi_off : Icons.cloud_off,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            switch (kind) {
              SolverFailureKind.noConnection => L.of(context).failedOffline,
              SolverFailureKind.serviceUnreachable =>
                L.of(context).failedServiceUnreachable,
              _ => L.of(context).failedGeneric,
            },
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            switch (kind) {
              SolverFailureKind.noConnection => L.of(context).errorNoConnection,
              SolverFailureKind.serviceUnreachable =>
                L.of(context).errorServiceUnreachable,
              SolverFailureKind.timeout => L.of(context).errorTimeout,
              SolverFailureKind.serverError => L.of(context).errorServer,
              null => L.of(context).errorUnknown,
            },
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            L.of(context).failedDataKept,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () {
              cubit.runCalculation();
              context.go('/calculator/solving');
            },
            child: Text(L.of(context).ctaRetry),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/calculator/review'),
            child: Text(L.of(context).ctaBackToData),
          ),
        ],
      ),
    );
  }
}
