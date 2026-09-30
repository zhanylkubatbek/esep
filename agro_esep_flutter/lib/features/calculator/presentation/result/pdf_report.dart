import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/models/calculation_record.dart';
import '../../../../data/models/farm_model.dart';
import '../../../../data/normatives/normatives.dart';
import '../../../../data/project_content.dart';
import 'cost_breakdown.dart';
import '../../../../core/formatting.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Отчёт по расчёту в PDF — для предъявления в банк, райуправление
/// или просто чтобы показать агроному на бумаге.
///
/// Шрифт встраивается из assets: стандартные шрифты PDF (Helvetica)
/// не содержат кириллицы, и без встраивания весь текст вышел бы
/// пустыми прямоугольниками.
class PdfReport {
  const PdfReport({
    required this.record,
    required this.normatives,
    required this.l,
    required this.content,
    this.farmTypeLabel,
  });

  final CalculationRecord record;
  final Normatives normatives;

  /// Отчёт печатается на языке, выбранном в приложении: строки и длинные
  /// тексты проекта передаются снаружи, экраном.
  final L l;
  final ProjectContent content;

  /// Локализованное название типа хозяйства. Передаётся снаружи:
  /// в записи хранится идентификатор, а перевод знает только UI.
  final String? farmTypeLabel;

  static const _ink = PdfColor.fromInt(0xFF1A2E28);
  static const _heading = PdfColor.fromInt(0xFF132A4D);
  static const _muted = PdfColor.fromInt(0xFF5B6F66);
  static const _line = PdfColor.fromInt(0xFFDCE3DF);
  static const _accent = PdfColor.fromInt(0xFFE1594A);

  Future<Uint8List> build() async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    final names = normatives.namesFor(l.localeName);
    final result = record.result;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 50),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          margin: const pw.EdgeInsets.only(top: 16),
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _line)),
          ),
          child: pw.Text(
            '${content.disclaimer}   ·   '
            '${l.pdfPage(context.pageNumber, context.pagesCount)}',
            style: const pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
        ),
        build: (context) => [
          _header(),
          pw.SizedBox(height: 20),
          _inputSection(names),
          pw.SizedBox(height: 18),
          if (result != null && result.status == SolveStatus.optimal) ...[
            _costBlock(result),
            pw.SizedBox(height: 18),
            _cropsTable(result, names),
            pw.SizedBox(height: 18),
            _livestockTable(result, names),
            pw.SizedBox(height: 18),
            _feedPurchaseTable(result, names),
            _costStructure(result),
          ] else if (record.status == RecordStatus.infeasible)
            _infeasibleBlock(result)
          else
            pw.Text(l.pdfNoResult, style: const pw.TextStyle(color: _muted)),
          pw.SizedBox(height: 20),
          _versionsNote(),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _header() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            l.pdfTitle,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _heading),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            content.organization,
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            l.pdfDate(Num.dateTime(record.createdAt)),
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
          pw.SizedBox(height: 10),
          pw.Container(height: 2, color: _accent, width: 60),
        ],
      );

  pw.Widget _sectionTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          text.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _muted,
            letterSpacing: 1,
          ),
        ),
      );

  pw.Widget _inputSection(NormativeNames names) {
    final rows = <List<String>>[
      if (farmTypeLabel != null) [l.pdfFarmType, farmTypeLabel!],
      for (final land in record.input.lands)
        [names.land(land.id), '${Num.area(land.areaHa)} ${l.unitHa}'],
      for (final entry in record.input.productionPlan.entries)
        [
          l.explainPlanFor(names.product(entry.key)),
          '${Num.area(entry.value)} ${l.unitTonsPerYear}',
        ],
      [
        l.pdfAvailableBreeds,
        record.input.breedProducts
                .map((bp) => names.breed(bp.breedId))
                .toSet()
                .join(', ')
                .ifEmptyThen('—'),
      ],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(l.pdfInputSection),
        _keyValueTable(rows),
      ],
    );
  }

  pw.Widget _keyValueTable(List<List<String>> rows) => pw.Table(
        border: pw.TableBorder(horizontalInside: pw.BorderSide(color: _line)),
        columnWidths: const {
          0: pw.FlexColumnWidth(2.4),
          1: pw.FlexColumnWidth(1),
        },
        children: [
          for (final row in rows)
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Text(row[0], style: const pw.TextStyle(fontSize: 10, color: _ink)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Text(
                    row[1],
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _heading,
                    ),
                  ),
                ),
              ],
            ),
        ],
      );

  pw.Widget _costBlock(OptimizationResult result) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: _heading,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              l.pdfTotalCost,
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.white,
                letterSpacing: 1,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '${Num.integer(result.totalCost ?? 0)} ${l.unitSom}',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ],
        ),
      );

  pw.Widget _cropsTable(OptimizationResult result, NormativeNames names) {
    final used = result.cropArea.fold<double>(0, (s, a) => s + a.areaHa);
    final total = record.totalLandHa;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(l.pdfWhatToSow(Num.area(used), Num.area(total))),
        _dataTable(
          headers: [l.pdfColCrop, l.pdfColLand, l.pdfColArea],
          rows: [
            for (final a in result.cropArea)
              [
                names.crop(a.cropId),
                names.land(a.landId),
                Num.area(a.areaHa),
              ],
          ],
        ),
        if (total - used > 0.01)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Text(
              l.pdfUnusedLand(Num.area(total - used)),
              style: const pw.TextStyle(fontSize: 8.5, color: _muted),
            ),
          ),
      ],
    );
  }

  pw.Widget _livestockTable(OptimizationResult result, NormativeNames names) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle(l.pdfHowManyHeads(record.totalHeads)),
          _dataTable(
            headers: [l.pdfColBreed, l.pdfColDirection, l.pdfColHeads],
            rows: [
              for (final a in result.livestock)
                [
                  names.breed(a.breedId),
                  names.product(a.productId),
                  '${a.heads}',
                ],
            ],
          ),
        ],
      );

  /// Что придётся докупить — переменные z[j] из (1.3).
  ///
  /// Блок печатается всегда, в том числе со строкой «закупка не
  /// требуется»: отсутствие раздела читалось бы как забытый пункт,
  /// а самообеспеченность кормами — это результат, а не пустота.
  pw.Widget _feedPurchaseTable(OptimizationResult result, NormativeNames names) {
    if (result.feedPurchase.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle(l.pdfFeedPurchase),
          pw.Text(
            l.pdfSelfSufficient,
            style: const pw.TextStyle(fontSize: 8.5, color: _muted),
          ),
          pw.SizedBox(height: 18),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(l.pdfFeedPurchase),
        _dataTable(
          headers: [l.pdfColFeed, l.pdfColTons, l.pdfColSum],
          rows: [
            for (final p in result.feedPurchase)
              [names.crop(p.cropId), Num.area(p.tons), Num.integer(p.cost)],
          ],
        ),
        pw.SizedBox(height: 18),
      ],
    );
  }

  /// Структура затрат — слагаемые целевой функции (1.1).
  /// Если разбивка не сходится с итогом решателя, блок не печатается:
  /// в документе, который несут в банк, приблизительных долей быть не должно.
  pw.Widget _costStructure(OptimizationResult result) {
    final breakdown = CostBreakdown.of(result, normatives);
    if (!breakdown.matches(result.totalCost)) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(l.pdfCostStructure),
        _dataTable(
          headers: [l.pdfColItem, l.pdfColShare, l.pdfColSum],
          rows: [
            [l.resultCrops, '${breakdown.cropPercent} %', Num.integer(breakdown.cropCost)],
            [
              l.resultLivestock,
              '${breakdown.livestockPercent} %',
              Num.integer(breakdown.livestockCost),
            ],
            if (breakdown.hasPurchase)
              [
                l.resultPurchasedFeed,
                '${breakdown.purchasePercent} %',
                Num.integer(breakdown.purchaseCost),
              ],
          ],
        ),
      ],
    );
  }

  pw.Widget _infeasibleBlock(OptimizationResult? result) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _accent),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              l.infeasibleTitle,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _heading,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              result?.landHaMissing == null || result!.landHaMissing! <= 0
                  ? l.infeasibleFullDescription
                  : l.pdfMissingLand(Num.area(result.landHaMissing!)),
              style: const pw.TextStyle(fontSize: 10, color: _ink),
            ),
          ],
        ),
      );

  pw.Widget _dataTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) =>
      pw.Table(
        border: pw.TableBorder.all(color: _line, width: 0.5),
        columnWidths: const {
          0: pw.FlexColumnWidth(2),
          1: pw.FlexColumnWidth(1.6),
          2: pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEAF0EA)),
            children: [
              for (var i = 0; i < headers.length; i++)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    headers[i],
                    textAlign: i == headers.length - 1 ? pw.TextAlign.right : pw.TextAlign.left,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
            ],
          ),
          for (final row in rows)
            pw.TableRow(
              children: [
                for (var i = 0; i < row.length; i++)
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      row[i],
                      textAlign: i == row.length - 1 ? pw.TextAlign.right : pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: _ink,
                        fontWeight:
                            i == row.length - 1 ? pw.FontWeight.bold : pw.FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      );

  /// Версии обязательны в документе: без них расчёт нельзя
  /// воспроизвести после обновления нормативной базы.
  pw.Widget _versionsNote() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${l.contactsNormativesBase(record.normativesVersion)}'
            '${record.solverVersion == null ? '' : '   ·   ${l.solverLine(record.solverVersion!)}'}',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
          if (normatives.isDemo) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              l.pdfDemoWarning,
              style: pw.TextStyle(fontSize: 8, color: _accent, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ],
      );

  String _fileName() =>
      'raschet-${record.createdAt.toIso8601String().split('T').first}-${record.id}.pdf';

  String get fileName => _fileName();


}

extension on String {
  String ifEmptyThen(String fallback) => isEmpty ? fallback : this;
}
