import 'dart:convert';
import 'dart:io';

import 'package:agro_esep/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// Шрифт должен быть встроен в приложение, а не скачиваться при запуске:
/// приложение работает без интернета, и на телефоне без связи текст обязан
/// выглядеть так же, как в макете.
void main() {
  const family = 'Golos Text';

  test('тема использует встроенное семейство шрифтов', () {
    final theme = AppTheme.light;

    expect(theme.textTheme.bodyMedium?.fontFamily, family);
    expect(theme.textTheme.titleLarge?.fontFamily, family);
    expect(theme.appBarTheme.titleTextStyle?.fontFamily, family);
  });

  test('в pubspec объявлены все четыре начертания', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains("family: $family"));
    for (final weight in [400, 500, 600, 700]) {
      expect(pubspec, contains('weight: $weight'),
          reason: 'без начертания $weight движок рисовал бы поддельный жирный');
    }
  });

  test('файлы шрифта лежат в проекте', () {
    for (final name in [
      'GolosText-Regular',
      'GolosText-Medium',
      'GolosText-SemiBold',
      'GolosText-Bold',
    ]) {
      final file = File('assets/fonts/$name.ttf');
      expect(file.existsSync(), isTrue, reason: 'нет файла $name.ttf');
      expect(file.lengthSync(), greaterThan(10000));
    }
  });

  test('пакет загрузки шрифтов из сети не подключён', () {
    // google_fonts скачивал бы Golos Text при каждом первом запуске,
    // а без интернета подставлял бы системный шрифт.
    final lock = File('pubspec.lock').readAsStringSync();
    expect(lock, isNot(contains('google_fonts:')));
  });

  test('лицензии на шрифты приложены', () {
    final license = File('assets/fonts/OFL.txt');
    expect(license.existsSync(), isTrue);
    expect(license.readAsStringSync(), contains('Golos Text'));
  });

  test('шрифт объявлен в манифесте ресурсов сборки', () {
    // Проверяется собранное приложение, если оно есть: манифест —
    // единственное место, где видно, что ресурс реально попал внутрь.
    final manifest = File(
      'build/ios/iphonesimulator/Runner.app/Frameworks/App.framework/'
      'flutter_assets/FontManifest.json',
    );
    if (!manifest.existsSync()) {
      markTestSkipped('сборка отсутствует — запустите flutter build');
      return;
    }

    final families = (jsonDecode(manifest.readAsStringSync()) as List)
        .map((e) => (e as Map)['family'] as String)
        .toList();
    expect(families, contains(family));
  });
}
