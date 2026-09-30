import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/normatives/excel_import.dart';
import '../../../data/normatives/normatives.dart';
import '../../../data/normatives/normatives_repository.dart';

/// Режим администратора: сотрудник института обновляет нормативную базу
/// без выпуска новой версии в сторе.
///
/// Имена листов (`Угодья`, `Культуры`, …) не переводятся: это ключи,
/// по которым лист ищется в файле, а не подписи.
class NormativesImportScreen extends StatefulWidget {
  const NormativesImportScreen({
    super.key,
    required this.repository,
    required this.current,
    required this.currentSource,
  });

  final NormativesRepository repository;
  final Normatives current;
  final NormativesSource currentSource;

  @override
  State<NormativesImportScreen> createState() => _NormativesImportScreenState();
}

class _NormativesImportScreenState extends State<NormativesImportScreen> {
  List<ImportIssue> _issues = const [];
  Normatives? _preview;
  Map<String, dynamic>? _previewJson;
  bool _busy = false;
  _Notice? _notice;

  Future<void> _pickFile() async {
    setState(() {
      _busy = true;
      _issues = const [];
      _preview = null;
      _notice = null;
    });

    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        withData: true,
      );
      final bytes = picked?.files.single.bytes;
      if (bytes == null) {
        setState(() => _busy = false);
        return;
      }

      final result = ExcelNormativesImport.parse(bytes);
      if (!result.isSuccess) {
        setState(() {
          _issues = result.issues;
          _busy = false;
        });
        return;
      }

      // Разобрали успешно — но применяем только после того, как
      // сотрудник увидит, что именно загрузится.
      setState(() {
        _previewJson = result.json;
        _preview = Normatives.fromJson(result.json!);
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _issues = [ImportIssue(null, null, ImportIssueKind.fileUnreadable, '$e')];
        _busy = false;
      });
    }
  }

  Future<void> _apply() async {
    final preview = _preview;
    final json = _previewJson;
    if (preview == null || json == null) return;

    await widget.repository.saveImported(preview, json);
    if (!mounted) return;
    setState(() {
      _notice = _Notice.saved;
      _preview = null;
      _previewJson = null;
    });
  }

  Future<void> _resetToBundled() async {
    await widget.repository.clearImported();
    if (!mounted) return;
    setState(() => _notice = _Notice.resetToBundled);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.adminTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _CurrentBase(
            normatives: widget.current,
            source: widget.currentSource,
          ),
          const SizedBox(height: 20),
          if (_notice != null) ...[
            _Banner(
              text: switch (_notice!) {
                _Notice.saved => l.adminSavedNotice,
                _Notice.resetToBundled => l.adminResetNotice,
              },
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
          ],
          if (_issues.isNotEmpty) ...[
            _IssueList(issues: _issues),
            const SizedBox(height: 16),
          ],
          if (_preview != null) ...[
            _Preview(normatives: _preview!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _apply,
              child: Text(l.adminApply),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() {
                _preview = null;
                _previewJson = null;
              }),
              child: Text(l.adminCancel),
            ),
          ] else ...[
            FilledButton(
              onPressed: _busy ? null : _pickFile,
              child: Text(_busy ? l.adminReadingFile : l.adminPickFile),
            ),
            const SizedBox(height: 12),
            if (widget.currentSource == NormativesSource.imported)
              OutlinedButton(
                onPressed: _resetToBundled,
                child: Text(l.adminResetToBundled),
              ),
          ],
          const SizedBox(height: 28),
          const _FormatHelp(),
        ],
      ),
    );
  }
}

class _CurrentBase extends StatelessWidget {
  const _CurrentBase({required this.normatives, required this.source});

  final Normatives normatives;
  final NormativesSource source;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L.of(context).adminCurrentBase,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            _Row(label: L.of(context).adminVersion, value: normatives.version),
            _Row(
              label: L.of(context).adminSource,
              value: source == NormativesSource.bundled
                  ? L.of(context).adminSourceBundled
                  : L.of(context).adminSourceImported,
            ),
            _Row(
              label: L.of(context).adminLandsCount,
              value: '${normatives.lands.length}',
            ),
            _Row(
              label: L.of(context).adminCropsCount,
              value: '${normatives.crops.length}',
            ),
            _Row(
              label: L.of(context).adminBreedsCount,
              value: '${normatives.breedProducts.length}',
            ),
            if (normatives.isDemo) ...[
              const SizedBox(height: 8),
              Text(
                L.of(context).adminDemoWarning,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      height: 1.4,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.normatives});

  final Normatives normatives;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L.of(context).adminPreviewTitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            _Row(label: L.of(context).adminVersion, value: normatives.version),
            _Row(
              label: L.of(context).adminLandsCount,
              value: '${normatives.lands.length}',
            ),
            _Row(
              label: L.of(context).adminCropsCount,
              value: '${normatives.crops.length}',
            ),
            _Row(
              label: L.of(context).adminBreedsCount,
              value: '${normatives.breedProducts.length}',
            ),
            const Divider(height: 24),
            // Названия показываются так, как записаны в файле: сотрудник
            // сверяет загруженное с таблицей, а не с переводом.
            Text(
              L.of(context)
                  .adminPreviewCrops(normatives.crops.map((c) => c.name).join(', ')),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              L.of(context).adminPreviewBreeds(normatives.breedsById.values
                  .map((v) => v.first.breedName)
                  .join(', ')),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({required this.issues});

  final List<ImportIssue> issues;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECE9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3C9C2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L.of(context).adminIssuesTitle(issues.length),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          for (final issue in issues.take(12))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${_describe(L.of(context), issue)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
              ),
            ),
          if (issues.length > 12)
            Text(
              L.of(context).adminIssuesMore(issues.length - 12),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
    );
  }

  /// Код ошибки разбора → строка для сотрудника. Лист и номер строки
  /// добавляются вокруг сообщения, чтобы было понятно, что править.
  static String _describe(L l, ImportIssue issue) {
    final message = switch (issue.kind) {
      ImportIssueKind.fileUnreadable =>
        l.importFileUnreadable(issue.detail ?? ''),
      ImportIssueKind.sheetMissing => l.importSheetMissing,
      ImportIssueKind.sheetEmpty => l.importSheetEmpty,
      ImportIssueKind.noRows => l.importNoRows,
      ImportIssueKind.idAndNameRequired => l.importIdAndNameRequired,
      ImportIssueKind.unknownLand => l.importUnknownLand(issue.detail ?? ''),
      ImportIssueKind.numbersRequired => l.importNumbersRequired,
      ImportIssueKind.nameRequired => l.importNameRequired,
      ImportIssueKind.unknownCropInHeader =>
        l.importUnknownCropInHeader(issue.detail ?? ''),
      ImportIssueKind.feedColumnsMissing => l.importFeedColumnsMissing,
      ImportIssueKind.unknownProduct =>
        l.importUnknownProduct(issue.detail ?? ''),
      ImportIssueKind.yieldMustBePositive => l.importYieldMustBePositive,
      ImportIssueKind.costMustBeNumber => l.importCostMustBeNumber,
      ImportIssueKind.feedNeedEmpty => l.importFeedNeedEmpty,
    };

    final sheet = issue.sheet ?? l.importFileLabel;
    final row = issue.row;
    return row == null
        ? l.importIssueAtSheet(sheet, message)
        : l.importIssueAtRow(sheet, row, message);
  }
}

class _FormatHelp extends StatelessWidget {
  const _FormatHelp();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    // Слева — имя листа, как оно должно называться в файле (не переводится),
    // справа — что в столбцах.
    final rows = [
      (ExcelNormativesImport.sheetLands, l.adminFormatLands),
      (ExcelNormativesImport.sheetCrops, l.adminFormatCrops),
      (ExcelNormativesImport.sheetProducts, l.adminFormatProducts),
      (ExcelNormativesImport.sheetBreeds, l.adminFormatBreeds),
      (ExcelNormativesImport.sheetMeta, l.adminFormatMeta),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.adminFormatTitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          l.adminFormatIntro,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
        ),
        const SizedBox(height: 10),
        for (final (sheet, columns) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                children: [
                  TextSpan(
                    text: '$sheet: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                    ),
                  ),
                  TextSpan(text: columns),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          l.adminFormatKyColumns,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l.adminFormatNote,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              height: 1.45,
            ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Что показать в зелёной плашке после действия. Хранится код,
/// а не текст: язык может смениться, пока плашка на экране.
enum _Notice { saved, resetToBundled }
