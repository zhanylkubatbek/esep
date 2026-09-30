from fastapi import FastAPI

from app.schemas import SolveRequest, SolveResponse
from app.solver.livestock import solve_livestock

app = FastAPI(title="AgroESEP solver", version="0.1.0")


@app.get("/v1/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/v1/solve", response_model=SolveResponse)
def solve(req: SolveRequest) -> SolveResponse:
    return solve_livestock(req)
