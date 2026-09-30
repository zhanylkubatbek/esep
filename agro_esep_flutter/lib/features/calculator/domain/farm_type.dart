import '../../../core/l10n/app_localizations.dart';

enum FarmType {
  peasant,
  cooperative,
  enterprise,
  household;

  /// Название и пояснение берутся из локализации: тексты видит
  /// пользователь, а enum — только идентификатор.
  String title(L l) => switch (this) {
        FarmType.peasant => l.farmPeasant,
        FarmType.cooperative => l.farmCooperative,
        FarmType.enterprise => l.farmEnterprise,
        FarmType.household => l.farmHousehold,
      };

  String description(L l) => switch (this) {
        FarmType.peasant => l.farmPeasantHint,
        FarmType.cooperative => l.farmCooperativeHint,
        FarmType.enterprise => l.farmEnterpriseHint,
        FarmType.household => l.farmHouseholdHint,
      };
}

enum CalculationPhase { input, solving, done, failed }

/// Предупреждение о неправдоподобном вводе. Не блокирует расчёт:
/// если значение верное, пользователь продолжает (экран 3 макетов).
/// Предупреждение о неправдоподобном плане.
///
/// Хранит числа, а не готовый текст: формулировка зависит от языка,
/// а язык знает только слой представления.
class PlausibilityWarning {
  const PlausibilityWarning(this.productId, this.landHa, this.maxReasonableT);

  final String productId;

  /// Вся площадь хозяйства, из которой считался предел.
  final double landHa;

  /// Сколько с этой площади можно получить по нормативам.
  final double maxReasonableT;
}
