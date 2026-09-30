"""Регрессия на контрольном примере — раздел 08 плана реализации.

Пока институт не передал реальную нормативную базу, контрольным примером
служит tests/fixtures.py (см. пояснение там). Как только появятся реальные
нормативы и контрольный пример от института — этот тест переписывается
на них, а число 5 519 985 перестаёт быть источником истины.
"""

from app.solver.livestock import solve_livestock
from tests.fixtures import reference_request


def test_reference_case_is_optimal_and_stable():
    result = solve_livestock(reference_request())

    assert result.status == "optimal"
    assert result.total_cost == 5519985.0
    assert result.shortage is None


def test_reference_case_does_not_use_rainfed_land():
    # богарная пашня дороже по стоимости за тонну корма для всех культур
    # фикстуры -> решение не должно её задействовать
    result = solve_livestock(reference_request())

    rainfed_allocations = [a for a in result.crop_area if a.land_id == "rainfed"]
    assert rainfed_allocations == []


def test_reference_case_meets_production_plan():
    result = solve_livestock(reference_request())
    livestock_by_key = {(l.breed_id, l.product_id): l.heads for l in result.livestock}

    milk = livestock_by_key[("alatau", "milk")] * 4.2 + livestock_by_key[("aulie", "milk")] * 3.6
    meat = livestock_by_key[("alatau", "meat")] * 0.19 + livestock_by_key[("aulie", "meat")] * 0.22

    assert milk >= 300
    assert meat >= 12


def test_reference_case_is_deterministic_across_runs():
    first = solve_livestock(reference_request())
    second = solve_livestock(reference_request())

    assert first.total_cost == second.total_cost
    assert first.livestock == second.livestock
