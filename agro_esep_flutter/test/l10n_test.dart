import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Страж полноты перевода: ключ, добавленный в русский шаблон и забытый
/// в кыргызском, иначе всплывёт только на устройстве — `gen-l10n`
/// молча подставит русский текст.
void main() {
  Map<String, dynamic> arb(String locale) => jsonDecode(
        File('lib/core/l10n/app_$locale.arb').readAsStringSync(),
      ) as Map<String, dynamic>;

  Set<String> keys(Map<String, dynamic> data) =>
      data.keys.where((k) => !k.startsWith('@')).toSet();

  test('наборы ключей ru и ky совпадают', () {
    final ru = keys(arb('ru'));
    final ky = keys(arb('ky'));

    expect(ru.difference(ky), isEmpty, reason: 'нет перевода на кыргызский');
    expect(ky.difference(ru), isEmpty, reason: 'ключа нет в шаблоне app_ru.arb');
  });

  test('ни одно значение не пустое', () {
    for (final locale in ['ru', 'ky']) {
      final data = arb(locale);
      for (final key in keys(data)) {
        expect(data[key], isNotEmpty, reason: '$locale: пустое значение у $key');
      }
    }
  });

  test('плейсхолдеры в переводе те же, что в шаблоне', () {
    final ru = arb('ru');
    final ky = arb('ky');
    final placeholder = RegExp(r'\{(\w+)');

    for (final key in keys(ru)) {
      final inRu = placeholder.allMatches(ru[key] as String).map((m) => m[1]).toSet();
      final inKy = placeholder.allMatches(ky[key] as String).map((m) => m[1]).toSet();
      expect(inKy, inRu, reason: 'разные подстановки у $key');
    }
  });

  /// Длинные тексты проекта живут в исходнике, а не в .arb, поэтому
  /// страж полноты у них свой. Забытое поле не падает и не пустует —
  /// оно просто остаётся русским на кыргызском экране, как это было
  /// с адресом института.
  group('ProjectContent', () {
    final source = File('lib/data/project_content.dart').readAsStringSync();

    String block(String locale) {
      final match = RegExp(
        'static const $locale = ProjectContent\\._\\(\n(.*?)\n  \\);',
        dotAll: true,
      ).firstMatch(source);
      expect(match, isNotNull, reason: 'не найден набор $locale');
      return match![1]!;
    }

    Set<String> literals(String body) => RegExp(r"'((?:[^'\\]|\\.)*)'")
        .allMatches(body)
        .map((m) => m[1]!)
        .toSet();

    test('оба языка заполняют все поля конструктора', () {
      final fields = RegExp(r'required this\.(\w+),')
          .allMatches(source)
          .map((m) => m[1]!)
          .toList();
      expect(fields, isNotEmpty, reason: 'поля конструктора не разобрались');

      for (final locale in ['ru', 'ky']) {
        final body = block(locale);
        for (final field in fields) {
          expect(
            RegExp('^\\s*$field:', multiLine: true).hasMatch(body),
            isTrue,
            reason: '$locale: не задано поле $field',
          );
        }
      }
    });

    test('ни одна строка не осталась общей для двух языков', () {
      expect(
        literals(block('ky')).intersection(literals(block('ru'))),
        isEmpty,
        reason: 'строка одинакова в ru и ky — значит не переведена',
      );
    });
  });
}
