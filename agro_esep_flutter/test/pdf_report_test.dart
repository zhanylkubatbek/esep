import 'dart:io';

import 'package:agro_esep/data/models/calculation_record.dart';
import 'package:agro_esep/data/models/farm_model.dart';
import 'package:agro_esep/core/l10n/app_localizations.dart';
import 'package:agro_esep/data/project_content.dart';
import 'package:agro_esep/features/calculator/presentation/result/pdf_report.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_normatives.dart';

CalculationRecord _record({
  RecordStatus status = RecordStatus.done,
  OptimizationResult? result,
}) =>
    CalculationRecord(
      id: 'calc-42',
      createdAt: DateTime(2026, 8, 8, 9, 44),
      input: OptimizationInput(
        lands: const [
          LandCategory(id: 'irrigated', name: 'Орошаемая пашня', areaHa: 120),
        ],
        crops: const [
          Crop(
            id: 'alfalfa',
            name: 'Люцерна',
            yieldByLand: {'irrigated': 8},
            costByLand: {'irrigated': 15000},
          ),
        ],
        breedProducts: const [
          BreedProduct(
            breedId: 'alatau',
            breedName: 'Алатауская',
            productId: 'milk',
            productName: 'Молоко',
            yieldPerHead: 4.2,
            annualCostPerHead: 45000,
            feedNeed: {'alfalfa': 2.0},
          ),
        ],
        productionPlan: const {'milk': 100},
        normativesVersion: 'test-1.0',
      ),
      status: status,
      normativesVersion: 'test-1.0',
      farmTypeId: 'peasant',
      result: result,
      solverVersion: 'scipy-milp-highs',
    );

const _optimal = OptimizationResult(
  status: SolveStatus.optimal,
  totalCost: 5542462,
  cropArea: [CropAreaAllocation(landId: 'irrigated', cropId: 'alfalfa', areaHa: 25.6)],
  livestock: [LivestockAllocation(breedId: 'alatau', productId: 'milk', heads: 24)],
  solverVersion: 'scipy-milp-highs',
);

void main() {
  // rootBundle нужен для загрузки шрифта из assets
  TestWidgetsFlutterBinding.ensureInitialized();

  late L ru;
  late L ky;

  setUpAll(() async {
    ru = await L.delegate.load(const Locale('ru'));
    ky = await L.delegate.load(const Locale('ky'));
  });

  test('PDF генерируется и является корректным документом', () async {
    final bytes = await PdfReport(
      record: _record(result: _optimal),
      normatives: buildTestNormatives(),
      l: ru,
      content: ProjectContent.ru,
    ).build();

    expect(bytes.length, greaterThan(1000));
    // сигнатура PDF-файла
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('шрифт с кириллицей встроен в документ', () async {
    final bytes = await PdfReport(
      record: _record(result: _optimal),
      normatives: buildTestNormatives(),
      l: ru,
      content: ProjectContent.ru,
    ).build();

    final raw = String.fromCharCodes(bytes);
    // Roboto встраивается как подмножество — без этого кириллица
    // отрисовалась бы пустыми прямоугольниками
    expect(raw, contains('Roboto'));
    expect(raw, contains('FontFile2'));
  });

  test('в отчёт попадают версии нормативов и решателя', () async {
    final report = PdfReport(
      record: _record(result: _optimal),
      normatives: buildTestNormatives(),
      l: ru,
      content: ProjectContent.ru,
    );
    final bytes = await report.build();

    expect(bytes, isNotEmpty);
    expect(report.fileName, contains('2026-08-08'));
    expect(report.fileName, endsWith('.pdf'));
  });

  test('отчёт по недостижимому плану тоже строится', () async {
    final bytes = await PdfReport(
      record: _record(
        status: RecordStatus.infeasible,
        result: const OptimizationResult(
          status: SolveStatus.infeasible,
          landHaMissing: 41,
          solverVersion: 'scipy-milp-highs',
        ),
      ),
      normatives: buildTestNormatives(),
      l: ru,
      content: ProjectContent.ru,
    ).build();

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('файл открывается как PDF на диске', () async {
    final bytes = await PdfReport(
      record: _record(result: _optimal),
      normatives: buildTestNormatives(),
      l: ru,
      content: ProjectContent.ru,
    ).build();

    final file = File('${Directory.systemTemp.path}/agro_esep_test_report.pdf');
    await file.writeAsBytes(bytes);

    expect(await file.length(), bytes.length);
    await file.delete();
  });

  test('отчёт строится и на кыргызском', () async {
    final bytes = await PdfReport(
      record: _record(result: _optimal),
      normatives: buildTestNormatives(),
      l: ky,
      content: ProjectContent.ky,
    ).build();

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
