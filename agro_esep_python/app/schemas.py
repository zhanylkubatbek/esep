"""Pydantic-модели запроса и ответа решателя.

Имена полей совпадают с обозначениями из формул (1.1)-(1.6) —
см. раздел 02 плана реализации ("Модель — зафиксированная спецификация"):

    s[k]        -> LandCategory.area_ha
    b[h]        -> SolveRequest.production_plan
    a[k][j]     -> Crop.yield_by_land
    c[k][j]     -> Crop.cost_by_land
    q[j][h][l]  -> BreedProduct.feed_need
    v[h][l]     -> BreedProduct.yield_per_head
    d[h][l]     -> BreedProduct.annual_cost_per_head
    x[k][j]     -> SolveResponse.crop_area
    y[h][l]     -> SolveResponse.livestock
"""

from typing import Literal

from pydantic import BaseModel, Field


class LandCategory(BaseModel):
    id: str
    name: str
    area_ha: float = Field(gt=0)


class Crop(BaseModel):
    id: str
    name: str
    # ключ — id категории угодий (LandCategory.id)
    yield_by_land: dict[str, float] = Field(default_factory=dict)  # a[k][j], т/га
    cost_by_land: dict[str, float] = Field(default_factory=dict)  # c[k][j], сом/га


class BreedProduct(BaseModel):
    """Одна пара (порода l, продукция h) — модель допускает,
    что одна порода даёт несколько видов продукции как отдельные
    решения y[h][l]."""

    breed_id: str
    breed_name: str
    product_id: str
    product_name: str
    yield_per_head: float = Field(gt=0)  # v[h][l], т/год на голову
    annual_cost_per_head: float = Field(ge=0)  # d[h][l], сом/год на голову
    # ключ — id культуры (Crop.id)
    feed_need: dict[str, float] = Field(default_factory=dict)  # q[j][h][l], т/год на голову


class SolveRequest(BaseModel):
    lands: list[LandCategory]
    crops: list[Crop]
    breed_products: list[BreedProduct]
    production_plan: dict[str, float]  # b[h], ключ — id продукции
    normatives_version: str = "unversioned"


class CropAreaAllocation(BaseModel):
    land_id: str
    crop_id: str
    area_ha: float


class LivestockAllocation(BaseModel):
    breed_id: str
    product_id: str
    heads: int


class Shortage(BaseModel):
    """Заполняется только при status == "infeasible" — во сколько
    не хватает земли, чтобы вырастить корм для выполнения плана
    производства при наименее затратном размещении культур."""

    land_ha_missing: float


class SolveResponse(BaseModel):
    status: Literal["optimal", "infeasible"]
    total_cost: float | None = None
    crop_area: list[CropAreaAllocation] | None = None
    livestock: list[LivestockAllocation] | None = None
    shortage: Shortage | None = None
    solver_version: str = "scipy-milp-highs"
