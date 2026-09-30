"""Решатель задачи (1.1)-(1.6) для животноводства.

Порядок переменных фиксирован явно (сначала все x[k][j] по
отсортированным id угодий/культур, затем все y[h][l] по
отсортированным id пород/продукции) — это и есть защита от
"правдоподобных, но неверных чисел" из-за рассинхронизации
порядка индексов между запросом и матрицами.
"""

from dataclasses import dataclass

import numpy as np
from scipy.optimize import Bounds, LinearConstraint, milp

from app.schemas import (
    CropAreaAllocation,
    LivestockAllocation,
    Shortage,
    SolveRequest,
    SolveResponse,
)

_ZERO_AREA_TOLERANCE = 1e-6
_ZERO_HEAD_TOLERANCE = 1e-6


@dataclass(frozen=True)
class _VariableIndex:
    """Индексация переменных x[k][j] и y[h][l] в едином векторе."""

    x_keys: list[tuple[str, str]]  # (land_id, crop_id)
    y_keys: list[tuple[str, str]]  # (breed_id, product_id)

    @property
    def size(self) -> int:
        return len(self.x_keys) + len(self.y_keys)

    def x_pos(self, land_id: str, crop_id: str) -> int | None:
        try:
            return self.x_keys.index((land_id, crop_id))
        except ValueError:
            return None

    def y_pos(self, breed_id: str, product_id: str) -> int:
        return len(self.x_keys) + self.y_keys.index((breed_id, product_id))


def _build_index(req: SolveRequest) -> _VariableIndex:
    land_ids = sorted(l.id for l in req.lands)
    crop_ids = sorted(c.id for c in req.crops)
    # x[k][j] создаётся только для пар, у которых культура задаёт
    # урожайность И затраты на этих угодьях — остальные пары не
    # участвуют в задаче (агрономически не растёт там).
    crops_by_id = {c.id: c for c in req.crops}
    x_keys = [
        (land_id, crop_id)
        for land_id in land_ids
        for crop_id in crop_ids
        if land_id in crops_by_id[crop_id].yield_by_land
        and land_id in crops_by_id[crop_id].cost_by_land
    ]
    y_keys = sorted((bp.breed_id, bp.product_id) for bp in req.breed_products)
    return _VariableIndex(x_keys=x_keys, y_keys=y_keys)


def _objective(req: SolveRequest, idx: _VariableIndex) -> np.ndarray:
    crops_by_id = {c.id: c for c in req.crops}
    bp_by_key = {(bp.breed_id, bp.product_id): bp for bp in req.breed_products}
    c = np.zeros(idx.size)
    for i, (land_id, crop_id) in enumerate(idx.x_keys):
        c[i] = crops_by_id[crop_id].cost_by_land[land_id]
    for (breed_id, product_id), bp in bp_by_key.items():
        c[idx.y_pos(breed_id, product_id)] = bp.annual_cost_per_head
    return c


def _integrality(idx: _VariableIndex) -> np.ndarray:
    # 0 = непрерывная (x), 1 = целочисленная (y)
    return np.array([0] * len(idx.x_keys) + [1] * len(idx.y_keys))


def _land_constraints(
    req: SolveRequest, idx: _VariableIndex, land_bound_scale: float = 1.0
) -> LinearConstraint:
    """(1.2) Σ_j x[k][j] ≤ s[k], по одной строке на категорию угодий."""
    rows = []
    upper = []
    for land in sorted(req.lands, key=lambda l: l.id):
        row = np.zeros(idx.size)
        for i, (land_id, _crop_id) in enumerate(idx.x_keys):
            if land_id == land.id:
                row[i] = 1.0
        rows.append(row)
        upper.append(land.area_ha * land_bound_scale)
    A = np.vstack(rows) if rows else np.zeros((0, idx.size))
    return LinearConstraint(A, lb=-np.inf, ub=np.array(upper))


def _feed_balance_constraints(req: SolveRequest, idx: _VariableIndex) -> LinearConstraint:
    """(1.3), согласованное упрощение: Σ_k a[k][j]·x[k][j] ≥ Σ_h,l q[j][h][l]·y[h][l]
    — выращено не меньше, чем требуется на корм (см. раздел 02 плана: при
    неотрицательных затратах на культуру решатель не станет пересевать сверх
    нормы, поэтому практический результат совпадает со строгим равенством
    из документа института)."""
    crops_by_id = {c.id: c for c in req.crops}
    rows = []
    for crop_id in sorted(crops_by_id):
        crop = crops_by_id[crop_id]
        row = np.zeros(idx.size)
        for i, (land_id, cid) in enumerate(idx.x_keys):
            if cid == crop_id:
                row[i] = crop.yield_by_land[land_id]
        for bp in req.breed_products:
            need = bp.feed_need.get(crop_id)
            if need:
                row[idx.y_pos(bp.breed_id, bp.product_id)] -= need
        rows.append(row)
    A = np.vstack(rows) if rows else np.zeros((0, idx.size))
    return LinearConstraint(A, lb=0.0, ub=np.inf)


def _production_plan_constraints(req: SolveRequest, idx: _VariableIndex) -> LinearConstraint:
    """(1.4) Σ_l v[h][l]·y[h][l] ≥ b[h], по одной строке на вид продукции."""
    rows = []
    lower = []
    for product_id in sorted(req.production_plan):
        row = np.zeros(idx.size)
        for bp in req.breed_products:
            if bp.product_id == product_id:
                row[idx.y_pos(bp.breed_id, bp.product_id)] = bp.yield_per_head
        rows.append(row)
        lower.append(req.production_plan[product_id])
    A = np.vstack(rows) if rows else np.zeros((0, idx.size))
    return LinearConstraint(A, lb=np.array(lower), ub=np.inf)


def _map_result(req: SolveRequest, idx: _VariableIndex, x: np.ndarray) -> SolveResponse:
    crop_area = [
        CropAreaAllocation(land_id=land_id, crop_id=crop_id, area_ha=round(x[i], 3))
        for i, (land_id, crop_id) in enumerate(idx.x_keys)
        if x[i] > _ZERO_AREA_TOLERANCE
    ]
    livestock = [
        LivestockAllocation(
            breed_id=breed_id,
            product_id=product_id,
            heads=round(x[idx.y_pos(breed_id, product_id)]),
        )
        for breed_id, product_id in idx.y_keys
        if x[idx.y_pos(breed_id, product_id)] > _ZERO_HEAD_TOLERANCE
    ]
    cost = _objective(req, idx)
    return SolveResponse(
        status="optimal",
        total_cost=round(float(cost @ x), 2),
        crop_area=crop_area,
        livestock=livestock,
    )


def _estimate_land_shortage(req: SolveRequest, idx: _VariableIndex) -> Shortage:
    """При infeasible: решаем ту же задачу без ограничения (1.2) на землю,
    чтобы понять, сколько земли не хватает при прежнем плане производства —
    ровно логика экрана "план недостижим, не хватает +N га"."""
    c = _objective(req, idx)
    constraints = [
        _land_constraints(req, idx, land_bound_scale=1e9),  # фактически без ограничения
        _feed_balance_constraints(req, idx),
        _production_plan_constraints(req, idx),
    ]
    result = milp(
        c=c,
        constraints=constraints,
        integrality=_integrality(idx),
        bounds=Bounds(lb=0, ub=np.inf),
    )
    if not result.success:
        # даже без ограничения на землю решения нет — дело не в земле
        # (например, план производства недостижим ни при каких вводных)
        return Shortage(land_ha_missing=0.0)

    required_by_land: dict[str, float] = {}
    for i, (land_id, _crop_id) in enumerate(idx.x_keys):
        required_by_land[land_id] = required_by_land.get(land_id, 0.0) + result.x[i]

    available_by_land = {land.id: land.area_ha for land in req.lands}
    missing = sum(
        max(0.0, required_by_land.get(land_id, 0.0) - available_by_land.get(land_id, 0.0))
        for land_id in required_by_land
    )
    return Shortage(land_ha_missing=round(missing, 1))


def solve_livestock(req: SolveRequest) -> SolveResponse:
    idx = _build_index(req)
    c = _objective(req, idx)
    constraints = [
        _land_constraints(req, idx),
        _feed_balance_constraints(req, idx),
        _production_plan_constraints(req, idx),
    ]
    result = milp(
        c=c,
        constraints=constraints,
        integrality=_integrality(idx),
        bounds=Bounds(lb=0, ub=np.inf),
    )
    if not result.success:
        return SolveResponse(status="infeasible", shortage=_estimate_land_shortage(req, idx))
    return _map_result(req, idx, result.x)
