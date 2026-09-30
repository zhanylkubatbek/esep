import 'farm_model.dart';

/// Состояние сохранённого расчёта. Расчёт выполняется на устройстве,
/// поэтому промежуточного состояния «ждёт связи» больше нет: он либо
/// посчитан, либо признан невыполнимым, либо не удался.
enum RecordStatus { done, infeasible, failed }

/// Один расчёт целиком: что ввели, что получили и на каких версиях
/// нормативов и решателя. Без версий старый расчёт невозможно
/// воспроизвести после обновления нормативной базы.
class CalculationRecord {
  const CalculationRecord({
    required this.id,
    required this.createdAt,
    required this.input,
    required this.status,
    required this.normativesVersion,
    this.farmTypeId,
    this.result,
    this.solverVersion,
  });

  final String id;
  final DateTime createdAt;
  final OptimizationInput input;
  final RecordStatus status;
  final String normativesVersion;
  /// Идентификатор типа хозяйства (FarmType.name), а не перевод:
  /// переведённая строка как ключ ломалась бы при смене языка.
  final String? farmTypeId;
  final OptimizationResult? result;
  final String? solverVersion;

  double get totalLandHa => input.lands.fold(0, (sum, l) => sum + l.areaHa);

  int get totalHeads =>
      result?.livestock.fold<int>(0, (sum, l) => sum + l.heads) ?? 0;

  CalculationRecord copyWith({
    RecordStatus? status,
    OptimizationResult? result,
    String? solverVersion,
  }) =>
      CalculationRecord(
        id: id,
        createdAt: createdAt,
        input: input,
        status: status ?? this.status,
        normativesVersion: normativesVersion,
        farmTypeId: farmTypeId,
        result: result ?? this.result,
        solverVersion: solverVersion ?? this.solverVersion,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'input': input.toJson(),
        'status': status.name,
        'normatives_version': normativesVersion,
        'farm_type_id': farmTypeId,
        'result': result?.toJson(),
        'solver_version': solverVersion,
      };

  factory CalculationRecord.fromJson(Map<String, dynamic> json) => CalculationRecord(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        input: OptimizationInput.fromJson(
          Map<String, dynamic>.from(json['input'] as Map),
        ),
        status: RecordStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => RecordStatus.failed,
        ),
        normativesVersion: json['normatives_version'] as String,
        farmTypeId: json['farm_type_id'] as String?,
        result: json['result'] == null
            ? null
            : OptimizationResult.fromJson(
                Map<String, dynamic>.from(json['result'] as Map),
              ),
        solverVersion: json['solver_version'] as String?,
      );
}
