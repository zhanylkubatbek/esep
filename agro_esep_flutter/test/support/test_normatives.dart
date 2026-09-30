import 'package:agro_esep/data/normatives/normatives.dart';

/// Нормативы для тестов — задаются прямо в коде, а не читаются из assets:
/// тесты не должны падать при замене демонстрационной базы на реальную.
Normatives buildTestNormatives() => Normatives.fromJson({
      'version': 'test-1.0',
      'is_demo': true,
      'lands': [
        {'id': 'irrigated', 'name': 'Орошаемая пашня'},
        {'id': 'rainfed', 'name': 'Богарная пашня'},
        {'id': 'pasture', 'name': 'Пастбища'},
      ],
      'crops': [
        {
          'id': 'alfalfa',
          'name': 'Люцерна',
          'yield_by_land': {'irrigated': 8.0, 'rainfed': 4.0},
          'cost_by_land': {'irrigated': 15000, 'rainfed': 12000},
          'purchase_price_per_ton': 12000,
        },
        // Растёт только на пастбище — на нём проверяется, что культура,
        // которую негде посеять, всё равно остаётся в задаче.
        {
          'id': 'pasture_grass',
          'name': 'Пастбищный корм',
          'yield_by_land': {'pasture': 3.0},
          'cost_by_land': {'pasture': 1500},
          'purchase_price_per_ton': 3500,
        },
      ],
      'products': [
        {'id': 'milk', 'name': 'Молоко', 'unit': 'т/год'},
        {'id': 'meat', 'name': 'Мясо (привес)', 'unit': 'т/год'},
      ],
      'breed_products': [
        {
          'breed_id': 'alatau',
          'breed_name': 'Алатауская',
          'product_id': 'milk',
          'product_name': 'Молоко',
          'yield_per_head': 4.2,
          'annual_cost_per_head': 45000,
          'feed_need': {'alfalfa': 2.0, 'pasture_grass': 7.5},
        },
        {
          'breed_id': 'kyrgyz_meat',
          'breed_name': 'Кыргызская мясная',
          'product_id': 'meat',
          'product_name': 'Мясо (привес)',
          'yield_per_head': 0.26,
          'annual_cost_per_head': 29000,
          'feed_need': {'alfalfa': 1.3, 'pasture_grass': 8.5},
        },
      ],
      'plausibility': {
        'max_milk_t_per_ha': 1.2,
        'max_meat_t_per_ha': 0.12,
      },
    });
