import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/calculation_record.dart';
import '../../../data/normatives/normatives.dart';
import '../domain/calculation_diff.dart';
import '../../../core/l10n/app_localizations.dart';

/// Сравнение двух расчётов: главное здесь — разница в сомах.
/// Без неё хозяйство не поймёт, зачем менять привычный уклад.
class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({
    super.key,
    required this.first,
    required this.second,
    required this.normatives,
  });

  final CalculationRecord first;
  final CalculationRecord second;
  final Normatives normatives;

  @override
  Widget build(BuildContext context) {
    final diff = CalculationDiff.of(
      first,
      second,
      normatives,
      languageCode: L.of(context).localeName,
    );

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).compareTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _VariantCard(
                    caption: L.of(context).compareBefore,
                    record: diff.before,
                    highlighted: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VariantCard(
                    caption: L.of(context).compareAfter,
                    record: diff.after,
                    highlighted: diff.isCheaper,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!diff.comparable)
            _Warning(
              text: L.of(context).compareIncomparable(
                diff.before.normativesVersion,
                diff.after.normativesVersion,
              ),
            )
          else
            _DeltaBanner(diff: diff),
          const SizedBox(height: 24),
          if (diff.crops.isNotEmpty) ...[
            _SectionLabel(L.of(context).compareCropChanges),
            const SizedBox(height: 12),
            for (final row in diff.crops) _DiffTile(row: row, unit: L.of(context).unitHa),
            const SizedBox(height: 24),
          ],
          if (diff.livestock.isNotEmpty) ...[
            _SectionLabel(L.of(context).compareHerdChanges),
            const SizedBox(height: 12),
            for (final row in diff.livestock) _DiffTile(row: row, unit: L.of(context).unitHeads),
          ],
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.caption,
    required this.record,
    required this.highlighted,
  });

  final String caption;
  final CalculationRecord record;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final heads = record.totalHeads;
    final area = record.result?.cropArea.fold<double>(0, (s, a) => s + a.areaHa) ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? AppColors.success : AppColors.divider,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            Num.integer(record.result?.totalCost ?? 0),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          const SizedBox(height: 2),
          Text(
            L.of(context).comparePerYear,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            L.of(context).compareStats(heads, Num.area(area)),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            Num.dateTime(record.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class _DeltaBanner extends StatelessWidget {
  const _DeltaBanner({required this.diff});

  final CalculationDiff diff;

  @override
  Widget build(BuildContext context) {
    final cheaper = diff.isCheaper;
    final color = cheaper ? AppColors.success : AppColors.warning;
    final amount = Num.integer(diff.costDelta.abs());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cheaper ? Icons.trending_down : Icons.trending_up, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L.of(context)
                      .comparePerYearAmount('${cheaper ? '−' : '+'}$amount'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            cheaper
                ? L.of(context).compareCheaperBy(diff.savingsPercent)
                : L.of(context).compareDearerBy(-diff.savingsPercent),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _DiffTile extends StatelessWidget {
  const _DiffTile({required this.row, required this.unit});

  final DiffRow row;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final (badge, badgeColor) = switch (row) {
      _ when row.isNew => (l.diffNew, AppColors.success),
      _ when row.isGone => (l.diffRemoved, AppColors.accent),
      _ when row.isUnchanged => (l.diffUnchanged, AppColors.textSecondary),
      _ when row.delta > 0 => (l.diffMore, AppColors.success),
      _ => (l.diffLess, AppColors.warning),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.heading,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: badgeColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.compareWas(Num.area(row.before)),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            Num.withUnit(Num.area(row.after), unit),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
