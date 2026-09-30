import 'package:flutter/material.dart';

/// Палитра снята со скриншотов сайта Института математики НАН КР —
/// см. раздел 05 плана реализации.
abstract final class AppColors {
  /// Тёмно-синий шапки сайта и заголовков.
  static const heading = Color(0xFF132A4D);

  /// Градиент хиро-блока: тёмно-зелёный переход.
  static const heroStart = Color(0xFF123B34);
  static const heroEnd = Color(0xFF1F5F52);

  /// Коралловый акцент кнопок «Позвонить», «Подробнее», CTA калькулятора.
  static const accent = Color(0xFFE1594A);
  static const accentPressed = Color(0xFFC64A3C);

  /// Фоны.
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF4F6F5);
  static const surfaceTint = Color(0xFFEAF0EA);

  /// Текст.
  static const textPrimary = Color(0xFF1A2E28);
  static const textSecondary = Color(0xFF5B6F66);

  static const divider = Color(0xFFDCE3DF);

  /// Семантические — для состояний расчёта, отдельно от акцента.
  static const success = Color(0xFF2E7D4F);
  static const warning = Color(0xFFB6552F);
}
