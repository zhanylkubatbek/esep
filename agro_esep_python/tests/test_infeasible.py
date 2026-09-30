"""Экран "план недостижим" из раздела 06 плана — здесь проверяется,
что решатель отдаёт понятную нехватку земли, а не просто падает."""

from app.schemas import LandCategory
from app.solver.livestock import solve_livestock
from tests.fixtures import BREED_PRODUCTS, CROPS, reference_request


def test_insufficient_land_is_reported_as_infeasible_with_shortage():
    request = reference_request()
    # той же план производства, но угодий заведомо недостаточно
    request.lands = [
        LandCategory(id="irrigated", name="Орошаемая пашня", area_ha=5),
        LandCategory(id="rainfed", name="Богарная пашня", area_ha=5),
    ]

    result = solve_livestock(request)

    assert result.status == "infeasible"
    assert result.shortage is not None
    assert result.shortage.land_ha_missing > 0
    assert result.total_cost is None
    assert result.livestock is None


def test_unreachable_plan_without_any_matching_breed_is_infeasible():
    request = reference_request(production_plan={"wool": 999})
    # ни одна порода/направление фикстуры не производит "wool"
    result = solve_livestock(request)

    assert result.status == "infeasible"
