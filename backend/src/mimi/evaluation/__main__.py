"""Run the InterpretMessage evaluation against the configured real LLM provider.

Manual use only; it calls the real provider and is never part of pytest/CI:

    python -m mimi.evaluation [--dataset PATH] [--output PATH]

Requires the same ``MIMI_*`` settings as the application. The exit code does
not reflect evaluation quality; it is non-zero only for an unusable dataset or
configuration.
"""

import argparse
import re
import sys
from collections.abc import Sequence
from datetime import UTC, datetime
from pathlib import Path

from mimi.composition import build_llm_provider
from mimi.config import get_settings
from mimi.evaluation.interpretation import (
    CaseResult,
    DatasetError,
    ModelInfo,
    build_report,
    format_summary,
    load_dataset,
    run_evaluation,
    write_report,
)

EVALUATION_DIR = Path(__file__).resolve().parents[3] / "evals" / "interpretation"
DEFAULT_DATASET = EVALUATION_DIR / "dataset.v1.jsonl"
REPORTS_DIR = EVALUATION_DIR / "reports"


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="python -m mimi.evaluation",
        description="Evaluate InterpretMessage with the configured LLM provider.",
    )
    parser.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    parser.add_argument(
        "--output",
        type=Path,
        help=f"report path (default: {REPORTS_DIR}/<timestamp>-<model>.json)",
    )
    args = parser.parse_args(argv)

    try:
        dataset = load_dataset(args.dataset)
    except DatasetError as exc:
        print(f"Invalid dataset: {exc}", file=sys.stderr)
        return 2
    try:
        settings = get_settings()
        llm = build_llm_provider(settings)
    except ValueError as exc:  # includes settings validation errors
        print(f"Invalid configuration: {exc}", file=sys.stderr)
        return 2
    assert settings.llm_model is not None  # checked by build_llm_provider
    model = ModelInfo(provider=settings.llm_provider.value, name=settings.llm_model)

    def report_progress(result: CaseResult) -> None:
        print(f"{result.status.value:<5} {result.case.id}", flush=True)

    run = run_evaluation(dataset, llm, model, on_result=report_progress)
    report = build_report(run)
    output = args.output or REPORTS_DIR / _report_name(run.started_at, model.name)
    write_report(report, output)
    print()
    print(format_summary(report))
    print(f"\nReport: {output}")
    return 0


def _report_name(started_at: datetime, model_name: str) -> str:
    timestamp = started_at.astimezone(UTC).strftime("%Y%m%dT%H%M%SZ")
    return f"{timestamp}-{re.sub(r'[^A-Za-z0-9._-]', '_', model_name)}.json"


if __name__ == "__main__":
    sys.exit(main())
