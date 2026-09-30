import 'package:agro_esep/data/normatives/normatives.dart';
import 'package:flutter_test/flutter_test.dart';

/// Вторая половина перевода: строки интерфейса лежат в .arb, а названия
/// культур, угодий и пород приходят из нормативной базы.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Normatives bundled;

  setUpAll(() async => bundled = await Normatives.loadFromAssets());

  test('встроенная база отдаёт кыргызские названия', () {
    final ky = bundled.namesFor('ky');

    expect(ky.land('irrigated'), 'Сугат айдоо жери');
    expect(ky.crop('alfalfa'), 'Беде (чөп)');
    expect(ky.product('milk'), 'Сүт');
    expect(ky.breed('alatau'), 'Алатоо тукуму');
    expect(ky.unit('milk'), 'т/жыл');
  });

  test('русская локаль берёт названия из самих записей', () {
    final ru = bundled.namesFor('ru');

    expect(ru.land('irrigated'), 'Орошаемая пашня');
    expect(ru.crop('alfalfa'), 'Люцерна (сено)');
    expect(ru.product('milk'), 'Молоко');
    expect(ru.breed('alatau'), 'Алатауская');
    expect(ru.unit('milk'), 'т/год');
  });

  test('во встроенной базе переведено всё, что видит пользователь', () {
    // Проверяется наличие перевода в базе, а не отличие от русского:
    // часть терминов («т», «силос») в обоих языках пишется одинаково.
    for (final land in bundled.lands) {
      expect(land.nameKy, isNotNull, reason: 'угодье ${land.id}');
    }
    for (final product in bundled.products) {
      expect(product.nameKy, isNotNull, reason: 'продукция ${product.id}');
      expect(product.unitKy, isNotNull, reason: 'единица ${product.id}');
    }
    for (final crop in bundled.crops) {
      expect(bundled.cropNamesKy, contains(crop.id), reason: 'культура ${crop.id}');
    }
    for (final id in bundled.breedsById.keys) {
      expect(bundled.breedNamesKy, contains(id), reason: 'порода $id');
    }
  });

  test('база без перевода не ломается — остаётся русское название', () {
    final oneLanguage = Normatives.fromJson({
      'version': 'test-1.0',
      'lands': [
        {'id': 'irrigated', 'name': 'Орошаемая пашня'},
      ],
      'crops': [
        {'id': 'alfalfa', 'name': 'Люцерна', 'yield_by_land': {}, 'cost_by_land': {}},
      ],
      'products': [
        {'id': 'milk', 'name': 'Молоко', 'unit': 'т/год'},
      ],
      'breed_products': const [],
    });

    final ky = oneLanguage.namesFor('ky');
    expect(ky.land('irrigated'), 'Орошаемая пашня');
    expect(ky.crop('alfalfa'), 'Люцерна');
    expect(ky.unit('milk'), 'т/год');
  });

  test('незнакомый id показывается как есть, а не пустой строкой', () {
    final ky = bundled.namesFor('ky');

    expect(ky.crop('unknown_crop'), 'unknown_crop');
    expect(ky.land('unknown_land'), 'unknown_land');
  });
}
