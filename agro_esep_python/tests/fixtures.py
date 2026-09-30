"""Тестовый набор данных для регрессии решателя.

Важно: это НЕ те цифры из демонстрации института ("10 592 100 сом"),
описанной в анализе проекта — исходные параметры (урожайность, затраты,
рационы) для того примера нам не передавались, только итоговый результат.
Подставлять их задним числом означало бы подгонять вход под ответ.

Здесь — свой небольшой, внутренне согласованный набор: 2 категории угодий,
3 культуры, 2 породы x 2 направления продукции. Числа правдоподобны для
условий Кыргызстана, но условны. Как только институт передаст реальную
нормативную базу и контрольный пример, этот файл замещается ими, а тест
на точное значение затрат обновляется.
"""

from app.schemas import BreedProduct, Crop, LandCategory, SolveRequest

LANDS = [
    LandCategory(id="irrigated", name="Орошаемая пашня", area_ha=120),
    LandCategory(id="rainfed", name="Богарная пашня", area_ha=200),
]

CROPS = [
    Crop(
        id="alfalfa",
        name="Люцерна",
        yield_by_land={"irrigated": 8.0, "rainfed": 4.0},  # т/га
        cost_by_land={"irrigated": 15000, "rainfed": 12000},  # сом/га
    ),
    Crop(
        id="silage_corn",
        name="Силосная кукуруза",
        yield_by_land={"irrigated": 45.0, "rainfed": 20.0},
        cost_by_land={"irrigated": 18000, "rainfed": 14000},
    ),
    Crop(
        id="barley",
        name="Ячмень",
        yield_by_land={"irrigated": 4.0, "rainfed": 2.2},
        cost_by_land={"irrigated": 10000, "rainfed": 8000},
    ),
]

BREED_PRODUCTS = [
    BreedProduct(
        breed_id="alatau",
        breed_name="Алатауская",
        product_id="milk",
        product_name="Молоко",
        yield_per_head=4.2,  # т/год
        annual_cost_per_head=45000,
        feed_need={"alfalfa": 2.0, "silage_corn": 5.0, "barley": 0.8},
    ),
    BreedProduct(
        breed_id="alatau",
        breed_name="Алатауская",
        product_id="meat",
        product_name="Мясо (привес)",
        yield_per_head=0.19,
        annual_cost_per_head=25000,
        feed_need={"alfalfa": 1.0, "silage_corn": 3.0, "barley": 0.5},
    ),
    BreedProduct(
        breed_id="aulie",
        breed_name="Аулиеатинская",
        product_id="milk",
        product_name="Молоко",
        yield_per_head=3.6,
        annual_cost_per_head=42000,
        feed_need={"alfalfa": 1.8, "silage_corn": 4.5, "barley": 0.7},
    ),
    BreedProduct(
        breed_id="aulie",
        breed_name="Аулиеатинская",
        product_id="meat",
        product_name="Мясо (привес)",
        yield_per_head=0.22,
        annual_cost_per_head=27000,
        feed_need={"alfalfa": 1.1, "silage_corn": 3.2, "barley": 0.55},
    ),
]


def reference_request(production_plan: dict[str, float] | None = None) -> SolveRequest:
    return SolveRequest(
        lands=LANDS,
        crops=CROPS,
        breed_products=BREED_PRODUCTS,
        production_plan=production_plan or {"milk": 300, "meat": 12},
        normatives_version="test-fixture-2026.08",
    )
