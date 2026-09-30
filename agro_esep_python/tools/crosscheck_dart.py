"""Сверка локального решателя приложения с HiGHS.

Dart-решатель написан вручную (симплекс + метод ветвей и границ), поэтому
его правильность нельзя принимать на веру. Скрипт берёт задачи, которые
приложение решило само, прогоняет их через scipy/HiGHS и сравнивает
значения целевой функции.

Сравниваются именно затраты, а не наборы переменных: у задачи может быть
несколько разных решений с одинаковой стоимостью, и это не ошибка.

Как получить входной файл:
    cd agro_esep_flutter
    flutter test test/local_solver_test.dart --run-skipped -t export

Запуск:
    python tools/crosscheck_dart.py /tmp/agro_esep_crosscheck.json
"""

from __future__ import annotations

import json
import sys

from app.schemas import SolveRequest
from app.solver.livestock import solve_livestock

# Относительный допуск: обе реализации считают в плавающей точке,
# но расходиться больше чем на сотую долю процента они не должны.
RELATIVE_TOLERANCE = 1e-4


def compare(path: str) -> int:
    cases = json.load(open(path, encoding="utf-8"))

    agreed = 0
    disagreed: list[str] = []
    status_mismatch: list[str] = []

    for case in cases:
        seed = case["seed"]
        dart = case["dart"]
        highs = solve_livestock(SolveRequest(**case["input"]))

        if dart["status"] != highs.status:
            status_mismatch.append(
                f"  задача {seed}: Dart={dart['status']}, HiGHS={highs.status}"
            )
            continue

        if highs.status != "optimal":
            agreed += 1
            continue

        dart_cost = dart["total_cost"]
        highs_cost = highs.total_cost
        scale = max(abs(highs_cost), 1.0)
        if abs(dart_cost - highs_cost) / scale > RELATIVE_TOLERANCE:
            disagreed.append(
                f"  задача {seed}: Dart={dart_cost:,.2f}, HiGHS={highs_cost:,.2f}, "
                f"разница {abs(dart_cost - highs_cost):,.2f}"
            )
        else:
            agreed += 1

    total = len(cases)
    print(f"Сверено задач: {total}")
    print(f"Совпало: {agreed}")

    if status_mismatch:
        print(f"\nРасхождение по разрешимости ({len(status_mismatch)}):")
        print("\n".join(status_mismatch[:20]))
    if disagreed:
        print(f"\nРасхождение по затратам ({len(disagreed)}):")
        print("\n".join(disagreed[:20]))

    if not status_mismatch and not disagreed:
        print("\nВсе задачи решены одинаково — локальный решатель совпадает с HiGHS.")
        return 0
    return 1


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        raise SystemExit(2)
    raise SystemExit(compare(sys.argv[1]))
