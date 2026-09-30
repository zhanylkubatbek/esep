import 'dart:ui' show Locale;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/settings_repository.dart';

/// Текущий язык интерфейса. Состояние — сама [Locale]:
/// отдельный класс состояния здесь был бы лишним.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._settings)
      : super(Locale(_settings.readLocaleCode() == 'ky' ? 'ky' : 'ru'));

  final SettingsRepository _settings;

  void setLocale(Locale locale) {
    if (locale == state) return;
    emit(locale);
    _settings.saveLocaleCode(locale.languageCode);
  }
}
