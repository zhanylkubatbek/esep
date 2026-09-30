import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import 'pdf_report.dart';

import '../../../../core/formatting.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/chart_colors.dart';
import '../../../../data/models/farm_model.dart';
import '../../../../data/normatives/normatives.dart';
import '../../../../data/project_content.dart';
import '../../../../widgets/share_bar.dart';
import '../../domain/farm_type.dart';
import '../cubit/calculator_cubit.dart';
import 'cost_breakdown.dart';

/// Экран рекомендации: сначала деньги, потом структура посевов,
/// потом поголовье — в том порядке, в каком возникают вопросы
/// хозяйства (экран 08 макетов).
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.cubit});

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

    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).resultTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/calculator'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: L.of(context).ctaSavePdf,
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _CostHeader(totalCost: result.totalCost ?? 0),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  title: L.of(context).resultWhatToSow,
                  trailing: L
                      .of(context)
                      .resultLandUsage(Num.area(usedHa), Num.area(cubit.state.totalLandHa)),
                ),
                const SizedBox(height: 12),
                ShareBar(
                  shares: _cropShares(result, names, L.of(context)),
                  remainder: (
                    label: L.of(context).resultUnused,
                    value: (cubit.state.totalLandHa - usedHa).clamp(0, double.infinity),
                  ),
                ),
                const SizedBox(height: 20),
                _CostStructure(result: result, normatives: n),
                const SizedBox(height: 28),
                _SectionLabel(title: L.of(context).resultHowManyHeads),
                const SizedBox(height: 12),
                for (final animal in result.livestock)
                  _LivestockRow(
                    breedName: names.breed(animal.breedId),
                    productName: names.product(animal.productId),
                    heads: animal.heads,
                  ),
                if (result.feedPurchase.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionLabel(title: L.of(context).resultFeedPurchase),
                  const SizedBox(height: 8),
                  Text(
                    L.of(context).resultFeedPurchaseHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 12),
                  for (final purchase in result.feedPurchase)
                    _PurchaseRow(
                      cropName: names.crop(purchase.cropId),
                      tons: purchase.tons,
                      cost: purchase.cost,
                    ),
                ],
                const SizedBox(height: 28),
                OutlinedButton(
                  onPressed: () => context.go('/calculator/explain'),
                  child: Text(L.of(context).ctaExplain),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go('/history'),
                  child: Text(L.of(context).ctaOpenHistory),
                ),
                const SizedBox(height: 20),
                Text(
                  ProjectContent.of(context).disclaimer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                ),
                if (n.isDemo) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${L.of(context).demoNormativesWarning(n.version)}\n'
                    '${L.of(context).solverLine(result.solverVersion)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Доли посевов. Слоты палитры назначаются по порядку; если культур
  /// окажется больше, чем слотов, хвост сворачивается в «прочие культуры» —
  /// сгенерированный пятый оттенок был бы неразличим под CVD.
  List<Share> _cropShares(
    OptimizationResult result,
    NormativeNames names,
    L l,
  ) {
    final sorted = result.cropArea.toList()
      ..sort((a, b) => b.areaHa.compareTo(a.areaHa));

    if (sorted.length <= ChartColors.maxSeries) {
      return [
        for (var i = 0; i < sorted.length; i++)
          Share(
            label: names.crop(sorted[i].cropId),
            value: sorted[i].areaHa,
            color: ChartColors.series[i],
            valueLabel: Num.withUnit(Num.area(sorted[i].areaHa), l.unitHa),
          ),
      ];
    }

    final head = sorted.take(ChartColors.maxSeries - 1).toList();
    final tail = sorted.skip(ChartColors.maxSeries - 1);
    final tailArea = tail.fold<double>(0, (sum, a) => sum + a.areaHa);
    return [
      for (var i = 0; i < head.length; i++)
        Share(
          label: names.crop(head[i].cropId),
          value: head[i].areaHa,
          color: ChartColors.series[i],
          valueLabel: Num.withUnit(Num.area(head[i].areaHa), l.unitHa),
        ),
      Share(
        label: '${l.resultOtherCrops} (${tail.length})',
        value: tailArea,
        color: ChartColors.series[ChartColors.maxSeries - 1],
        valueLabel: Num.withUnit(Num.area(tailArea), l.unitHa),
      ),
    ];
  }

  Future<void> _exportPdf(BuildContext context) async {
    final record = cubit.currentRecord;
    if (record == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L.of(context).notSavedYet)),
      );
      return;
    }

    final farmType = FarmType.values
        .where((t) => t.name == record.farmTypeId)
        .firstOrNull;
    final report = PdfReport(
      record: record,
      normatives: cubit.normatives,
      l: L.of(context),
      content: ProjectContent.of(context),
      farmTypeLabel: farmType?.title(L.of(context)),
    );
    await Printing.sharePdf(bytes: await report.build(), filename: report.fileName);
  }

}

class _CostHeader extends StatelessWidget {
  const _CostHeader({required this.totalCost});

  final double totalCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      color: AppColors.heading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L.of(context).resultCostLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Num.integer(totalCost),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                L.of(context).unitSom,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        if (trailing != null) Text(trailing!, style: style),
      ],
    );
  }
}



class _LivestockRow extends StatelessWidget {
  const _LivestockRow({
    required this.breedName,
    required this.productName,
    required this.heads,
  });

  final String breedName;
  final String productName;
  final int heads;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  productName.length > 3 ? productName.substring(0, 3).toUpperCase() : productName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.heroEnd,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breedName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.heading,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      productName.toLowerCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '$heads',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}

/// Строка закупки корма: сколько тонн и на какую сумму.
///
/// Показывается рядом с посевами, а не прячется в структуре затрат:
/// «докупить 40 т сена» — это отдельное решение хозяйства, которое
/// надо принять и профинансировать, а не просто доля в диаграмме.
class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({
    required this.cropName,
    required this.tons,
    required this.cost,
  });

  final String cropName;
  final double tons;
  final double cost;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
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
                  cropName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.heading,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Num.integer(cost)} ${l.unitSom}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            Num.withUnit(Num.area(tons), l.unitTons),
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

/// Структура затрат — слагаемые целевой функции (1.1).
/// Показывается только если разбивка сходится с итогом решателя:
/// расхождение означало бы рассогласование нормативов, и показывать
/// такие доли было бы обманом.
class _CostStructure extends StatelessWidget {
  const _CostStructure({required this.result, required this.normatives});

  final OptimizationResult result;
  final Normatives normatives;

  @override
  Widget build(BuildContext context) {
    final breakdown = CostBreakdown.of(result, normatives);
    if (!breakdown.matches(result.totalCost)) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title: L.of(context).resultCostStructure),
        const SizedBox(height: 12),
        ShareBar(
          height: 28,
          shares: [
            Share(
              label: L.of(context).resultCrops,
              value: breakdown.cropCost,
              color: ChartColors.slot1,
              valueLabel: '${Num.integer(breakdown.cropCost)} · ${breakdown.cropPercent} %',
            ),
            Share(
              label: L.of(context).resultLivestock,
              value: breakdown.livestockCost,
              color: ChartColors.slot2,
              valueLabel:
                  '${Num.integer(breakdown.livestockCost)} · ${breakdown.livestockPercent} %',
            ),
            // Третья доля появляется, только если корма действительно
            // покупались: нулевой сегмент в шкале выглядел бы как
            // расход, которого нет.
            if (breakdown.hasPurchase)
              Share(
                label: L.of(context).resultPurchasedFeed,
                value: breakdown.purchaseCost,
                color: ChartColors.slot3,
                valueLabel:
                    '${Num.integer(breakdown.purchaseCost)} · ${breakdown.purchasePercent} %',
              ),
          ],
        ),
      ],
    );
  }
}
