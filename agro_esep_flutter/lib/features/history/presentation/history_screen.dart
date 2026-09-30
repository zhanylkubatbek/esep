import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/calculation_record.dart';
import '../../../data/models/farm_model.dart';
import '../../../data/project_content.dart';
import '../../calculator/domain/farm_type.dart';
import '../../calculator/presentation/cubit/calculator_cubit.dart';
import '../../calculator/presentation/cubit/calculator_state.dart';
import '../../calculator/presentation/result/pdf_report.dart';
import 'comparison_screen.dart';
import '../../../core/formatting.dart';
import '../../../core/l10n/app_localizations.dart';

/// «Мои расчёты». Сохранённые расчёты открываются без интернета —
/// в районах это разница между «работает» и «не работает».
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  /// Режим выбора для сравнения. Включается кнопкой, а не длинным
  /// нажатием: длинное нажатие уже занято входом в режим администратора,
  /// и два разных смысла у одного жеста путали бы.
  bool _selecting = false;
  final Set<String> _selected = {};

  void _toggleSelection(String id) {
    setState(() {
      if (!_selected.remove(id)) {
        if (_selected.length >= 2) _selected.remove(_selected.first);
        _selected.add(id);
      }
    });
  }

  void _openComparison(List<CalculationRecord> records) {
    final chosen = records.where((r) => _selected.contains(r.id)).toList();
    if (chosen.length != 2) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComparisonScreen(
          first: chosen.first,
          second: chosen.last,
          normatives: widget.cubit.normatives,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      bloc: widget.cubit,
      builder: (context, state) {
        final records = widget.cubit.store.readAll();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _selecting
                  ? L.of(context).compareSelectedCount(_selected.length)
                  : L.of(context).historyTitle,
            ),
            actions: [
              if (records.where((r) => r.result != null).length >= 2)
                TextButton(
                  onPressed: () => setState(() {
                    _selecting = !_selecting;
                    _selected.clear();
                  }),
                  child: Text(
                    _selecting ? L.of(context).compareCancel : L.of(context).compareAction,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: records.isEmpty
              ? const _EmptyState()
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final record in records)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RecordCard(
                          record: record,
                          selecting: _selecting,
                          selected: _selected.contains(record.id),
                          onOpen: () {
                            if (_selecting) {
                              if (record.result != null) {
                                _toggleSelection(record.id);
                              }
                              return;
                            }
                            widget.cubit.loadRecord(record);
                            context.go(
                              record.status == RecordStatus.infeasible
                                  ? '/calculator/infeasible'
                                  : '/calculator/result',
                            );
                          },
                          onDelete: () async {
                            await widget.cubit.store.delete(record.id);
                            if (mounted) setState(() {});
                          },
                          onExportPdf: record.result == null
                              ? null
                              : () async {
                                  final farmType = FarmType.values
                                      .where((t) => t.name == record.farmTypeId)
                                      .firstOrNull;
                                  final report = PdfReport(
                                    record: record,
                                    normatives: widget.cubit.normatives,
                                    l: L.of(context),
                                    content: ProjectContent.of(context),
                                    farmTypeLabel:
                                        farmType?.title(L.of(context)),
                                  );
                                  await Printing.sharePdf(
                                    bytes: await report.build(),
                                    filename: report.fileName,
                                  );
                                },
                        ),
                      ),
                  ],
                ),
          floatingActionButton: _selecting
              ? FloatingActionButton.extended(
                  onPressed: _selected.length == 2
                      ? () => _openComparison(records)
                      : null,
                  backgroundColor: _selected.length == 2
                      ? AppColors.heading
                      : AppColors.divider,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.compare_arrows),
                  label: Text(L.of(context).compareSelected),
                )
              : FloatingActionButton.extended(
                  onPressed: () {
                    widget.cubit.reset();
                    context.go('/calculator/type');
                  },
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: Text(L.of(context).historyNewCalculation),
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              L.of(context).historyEmptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.heading,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              L.of(context).historyEmptyFull,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.selecting,
    required this.selected,
    required this.onOpen,
    required this.onDelete,
    required this.onExportPdf,
  });

  final CalculationRecord record;
  final bool selecting;
  final bool selected;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  /// null, если результата ещё нет — экспортировать нечего.
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final canOpen = record.result != null;

    return Card(
      // В режиме выбора отмеченная карточка обведена и помечена галочкой:
      // цвет рамки один не должен нести смысл.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.heading : AppColors.divider,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: canOpen ? onOpen : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selecting) ...[
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 20,
                      color: selected
                          ? AppColors.heading
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  _StatusChip(status: record.status),
                  const Spacer(),
                  Text(
                    Num.dateTime(record.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (!selecting && onExportPdf != null)
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: onExportPdf,
                      tooltip: L.of(context).ctaSavePdf,
                    ),
                  if (!selecting)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: onDelete,
                      tooltip: L.of(context).historyDelete,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${Num.area(record.totalLandHa)} ${L.of(context).unitHa} · '
                '${record.input.productionPlan.entries.map((e) => '${Num.area(e.value)} ${L.of(context).unitTons}').join(' · ')}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (record.result?.status == SolveStatus.optimal) ...[
                _MetricRow(
                  label: L.of(context).historyCosts,
                  value:
                      '${Num.integer(record.result!.totalCost ?? 0)} ${L.of(context).unitSom}',
                ),
                _MetricRow(
                  label: L.of(context).historyHeads,
                  value: L.of(context).historyHeadsValue(record.totalHeads),
                ),
              ] else if (record.status == RecordStatus.infeasible)
                Text(
                  L.of(context).historyInfeasible,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.accent),
                )
              else
                Text(
                  L.of(context).historyNoResult,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                '${L.of(context).normativesLine(record.normativesVersion)}'
                '${record.solverVersion == null ? '' : ' · ${L.of(context).solverLine(record.solverVersion!)}'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final RecordStatus status;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final (label, color) = switch (status) {
      RecordStatus.done => (l.statusDone, AppColors.success),
      RecordStatus.infeasible => (l.statusInfeasible, AppColors.accent),
      RecordStatus.failed => (l.statusFailed, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
