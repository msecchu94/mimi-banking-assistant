"""Evaluation of ``InterpretMessage`` against a versioned, labelled dataset.

Each case is interpreted end-to-end and compared field by field with its
expected ``Interpretation``. A case PASSes on an exact match, FAILs otherwise
and is an ERROR when the provider raises a known LLM error; errors are
reported but excluded from quality metrics.
"""

import hashlib
import json
import re
from collections.abc import Callable, Sequence
from dataclasses import dataclass, fields
from datetime import UTC, datetime
from decimal import Decimal, InvalidOperation
from enum import StrEnum
from pathlib import Path
from typing import Any

from pydantic import BaseModel, ConfigDict, ValidationError

from mimi.application.errors import LLMInvalidResponseError, LLMUnavailableError
from mimi.application.interpretation import Intent, Interpretation, PeriodReference
from mimi.application.llm import LLMProvider
from mimi.application.use_cases.interpret_message import (
    _ALLOWED_FIELDS,
    InterpretMessage,
)
from mimi.domain.enums import Currency, TransactionCategory, TransactionType

REPORT_SCHEMA_VERSION = 1

FIELDS: tuple[str, ...] = tuple(f.name for f in fields(Interpretation))
_REFERENCE_FIELDS = frozenset({"beneficiary_reference", "card_reference"})
_SET_FIELDS = frozenset({"invalid_fields", "unsupported_fields"})

_DATASET_NAME_PATTERN = re.compile(r".+\.(v[0-9]+)\.jsonl")
_TAG_PATTERN = re.compile(r"[a-z0-9]+(-[a-z0-9]+)*")

_ERRORS = (LLMUnavailableError, LLMInvalidResponseError)


class DatasetError(Exception):
    """The dataset cannot be used for evaluation."""


@dataclass(frozen=True)
class EvaluationCase:
    id: str
    message: str
    tags: tuple[str, ...]
    expected: Interpretation


@dataclass(frozen=True)
class Dataset:
    path: Path
    version: str
    sha256: str
    cases: tuple[EvaluationCase, ...]


class _ExpectedLine(BaseModel):
    model_config = ConfigDict(extra="forbid")

    intent: Intent
    amount: str | None = None
    currency: Currency | None = None
    beneficiary_reference: str | None = None
    card_reference: str | None = None
    category: TransactionCategory | None = None
    transaction_type: TransactionType | None = None
    period: PeriodReference | None = None
    comparison_period: PeriodReference | None = None
    invalid_fields: list[str] = []
    unsupported_fields: list[str] = []


class _CaseLine(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str
    message: str
    tags: list[str]
    expected: _ExpectedLine
    note: str | None = None


def load_dataset(path: Path) -> Dataset:
    """Load and validate a ``<name>.v<N>.jsonl`` dataset.

    Raises ``DatasetError`` naming the offending line on any invalid case.
    """
    name_match = _DATASET_NAME_PATTERN.fullmatch(path.name)
    if name_match is None:
        raise DatasetError(f"{path.name}: file name must end in '.v<N>.jsonl'")
    try:
        content = path.read_bytes()
    except OSError as exc:
        raise DatasetError(f"{path}: cannot be read ({exc.strerror})") from None

    cases: list[EvaluationCase] = []
    seen_ids: set[str] = set()
    for number, line in enumerate(content.decode("utf-8").splitlines(), start=1):
        if not line.strip():
            continue
        try:
            case = _parse_case(line)
        except (ValueError, ValidationError) as exc:
            raise DatasetError(f"{path.name}:{number}: {exc}") from None
        if case.id in seen_ids:
            raise DatasetError(f"{path.name}:{number}: duplicate id '{case.id}'")
        seen_ids.add(case.id)
        cases.append(case)

    if not cases:
        raise DatasetError(f"{path.name}: dataset has no cases")
    return Dataset(
        path=path,
        version=name_match.group(1),
        sha256=hashlib.sha256(content).hexdigest(),
        cases=tuple(cases),
    )


def _parse_case(line: str) -> EvaluationCase:
    raw = _CaseLine.model_validate(json.loads(line))
    if not raw.id.strip() or raw.id != raw.id.strip():
        raise ValueError("id must be non-empty without surrounding whitespace")
    if not raw.message.strip():
        raise ValueError("message must not be blank")
    if not raw.tags:
        raise ValueError("at least one tag is required")
    for tag in raw.tags:
        if not _TAG_PATTERN.fullmatch(tag):
            raise ValueError(f"tag '{tag}' must be lowercase kebab-case")
    if len(set(raw.tags)) != len(raw.tags):
        raise ValueError("tags must be unique")
    return EvaluationCase(
        id=raw.id,
        message=raw.message,
        tags=tuple(raw.tags),
        expected=_to_interpretation(raw.expected),
    )


def _to_interpretation(raw: _ExpectedLine) -> Interpretation:
    allowed = _ALLOWED_FIELDS[raw.intent]
    flagged = {*raw.invalid_fields, *raw.unsupported_fields}
    if disallowed := sorted(flagged - allowed):
        raise ValueError(f"{disallowed} cannot be flagged for {raw.intent}")
    for name in FIELDS:
        if name == "intent" or name in _SET_FIELDS or getattr(raw, name) is None:
            continue
        if name not in allowed:
            raise ValueError(f"'{name}' is not extracted for {raw.intent}")
        if name in flagged:
            raise ValueError(f"'{name}' cannot be both set and flagged")
    return Interpretation(
        intent=raw.intent,
        amount=None if raw.amount is None else _parse_amount(raw.amount),
        currency=raw.currency,
        beneficiary_reference=raw.beneficiary_reference,
        card_reference=raw.card_reference,
        category=raw.category,
        transaction_type=raw.transaction_type,
        period=raw.period,
        comparison_period=raw.comparison_period,
        invalid_fields=frozenset(raw.invalid_fields),
        unsupported_fields=frozenset(raw.unsupported_fields),
    )


def _parse_amount(text: str) -> Decimal:
    try:
        amount = Decimal(text)
    except InvalidOperation:
        raise ValueError(f"amount '{text}' is not a decimal number") from None
    if not amount.is_finite() or amount <= 0:
        raise ValueError(f"amount '{text}' must be a positive decimal number")
    return amount


class CaseStatus(StrEnum):
    PASS = "PASS"
    FAIL = "FAIL"
    ERROR = "ERROR"


@dataclass(frozen=True)
class CaseResult:
    case: EvaluationCase
    status: CaseStatus
    actual: Interpretation | None = None
    mismatched_fields: tuple[str, ...] = ()
    error_type: str | None = None


def _normalize_reference(value: str) -> str:
    return " ".join(value.split()).lower()


def _field_value(interpretation: Interpretation, name: str) -> Any:
    value = getattr(interpretation, name)
    if name in _REFERENCE_FIELDS and value is not None:
        return _normalize_reference(value)
    return value


def _is_set(value: Any) -> bool:
    return value is not None and value != frozenset()


def mismatched_fields(
    expected: Interpretation, actual: Interpretation
) -> tuple[str, ...]:
    """Fields whose values differ, comparing references normalized."""
    return tuple(
        name
        for name in FIELDS
        if _field_value(expected, name) != _field_value(actual, name)
    )


def evaluate_case(interpreter: InterpretMessage, case: EvaluationCase) -> CaseResult:
    """Interpret one case. Only known LLM errors are classified as ERROR."""
    try:
        actual = interpreter.execute(case.message)
    except _ERRORS as exc:
        return CaseResult(
            case=case, status=CaseStatus.ERROR, error_type=type(exc).__name__
        )
    mismatches = mismatched_fields(case.expected, actual)
    return CaseResult(
        case=case,
        status=CaseStatus.FAIL if mismatches else CaseStatus.PASS,
        actual=actual,
        mismatched_fields=mismatches,
    )


@dataclass(frozen=True)
class FieldAccuracy:
    correct: int
    total: int

    @property
    def accuracy(self) -> float | None:
        return _rate(self.correct, self.total)


@dataclass(frozen=True)
class Metrics:
    total: int
    passed: int
    failed: int
    errored: int
    field_accuracy: dict[str, FieldAccuracy]

    @property
    def exact_match_rate(self) -> float | None:
        return _rate(self.passed, self.passed + self.failed)


def _rate(numerator: int, denominator: int) -> float | None:
    return round(numerator / denominator, 4) if denominator else None


def compute_metrics(results: Sequence[CaseResult]) -> Metrics:
    """Aggregate results, excluding errors from quality metrics.

    Intent accuracy counts every scored case. Any other field counts only the
    cases where it is set in the expected or actual interpretation, so fields
    that are trivially unset on both sides do not inflate accuracy.
    """
    scored = [r for r in results if r.actual is not None]
    field_accuracy: dict[str, FieldAccuracy] = {}
    for name in FIELDS:
        relevant = [
            r
            for r in scored
            if name == "intent"
            or _is_set(getattr(r.case.expected, name))
            or _is_set(getattr(r.actual, name))
        ]
        correct = sum(1 for r in relevant if name not in r.mismatched_fields)
        field_accuracy[name] = FieldAccuracy(correct=correct, total=len(relevant))
    return Metrics(
        total=len(results),
        passed=sum(1 for r in results if r.status is CaseStatus.PASS),
        failed=sum(1 for r in results if r.status is CaseStatus.FAIL),
        errored=sum(1 for r in results if r.status is CaseStatus.ERROR),
        field_accuracy=field_accuracy,
    )


def metrics_by_tag(results: Sequence[CaseResult]) -> dict[str, Metrics]:
    tags = sorted({tag for r in results for tag in r.case.tags})
    return {
        tag: compute_metrics([r for r in results if tag in r.case.tags]) for tag in tags
    }


class InstructionsRecorder:
    """Delegating provider that fingerprints the instructions sent to the model,
    so reports reveal prompt changes between runs."""

    def __init__(self, llm: LLMProvider) -> None:
        self._llm = llm
        self.instructions_sha256: str | None = None

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        digest = hashlib.sha256(instructions.encode("utf-8")).hexdigest()
        if self.instructions_sha256 not in (None, digest):
            raise RuntimeError("instructions changed during an evaluation run")
        self.instructions_sha256 = digest
        return self._llm.generate_structured(
            instructions=instructions, input_text=input_text, output_type=output_type
        )


@dataclass(frozen=True)
class ModelInfo:
    provider: str
    name: str


@dataclass(frozen=True)
class EvaluationRun:
    dataset: Dataset
    model: ModelInfo
    instructions_sha256: str | None
    started_at: datetime
    finished_at: datetime
    results: tuple[CaseResult, ...]


def run_evaluation(
    dataset: Dataset,
    llm: LLMProvider,
    model: ModelInfo,
    on_result: Callable[[CaseResult], None] | None = None,
) -> EvaluationRun:
    """Interpret every case sequentially, once, through ``InterpretMessage``."""
    recorder = InstructionsRecorder(llm)
    interpreter = InterpretMessage(recorder)
    started_at = datetime.now(UTC)
    results: list[CaseResult] = []
    for case in dataset.cases:
        result = evaluate_case(interpreter, case)
        results.append(result)
        if on_result is not None:
            on_result(result)
    return EvaluationRun(
        dataset=dataset,
        model=model,
        instructions_sha256=recorder.instructions_sha256,
        started_at=started_at,
        finished_at=datetime.now(UTC),
        results=tuple(results),
    )


def interpretation_to_json(interpretation: Interpretation) -> dict[str, Any]:
    """Serialize only set fields, in the dataset's ``expected`` format."""
    data: dict[str, Any] = {}
    for name in FIELDS:
        value = getattr(interpretation, name)
        if not _is_set(value):
            continue
        if isinstance(value, frozenset):
            data[name] = sorted(value)
        elif isinstance(value, Decimal | StrEnum):
            data[name] = str(value)
        else:
            data[name] = value
    return data


def _metrics_to_json(metrics: Metrics) -> dict[str, Any]:
    return {
        "total": metrics.total,
        "passed": metrics.passed,
        "failed": metrics.failed,
        "errored": metrics.errored,
        "exact_match_rate": metrics.exact_match_rate,
        "field_accuracy": {
            name: {
                "correct": accuracy.correct,
                "total": accuracy.total,
                "accuracy": accuracy.accuracy,
            }
            for name, accuracy in metrics.field_accuracy.items()
        },
    }


def _case_header(case: EvaluationCase) -> dict[str, Any]:
    return {"id": case.id, "message": case.message, "tags": list(case.tags)}


def build_report(run: EvaluationRun) -> dict[str, Any]:
    results = run.results
    return {
        "report_schema_version": REPORT_SCHEMA_VERSION,
        "dataset": {
            "path": run.dataset.path.name,
            "version": run.dataset.version,
            "sha256": run.dataset.sha256,
            "case_count": len(run.dataset.cases),
        },
        "model": {"provider": run.model.provider, "name": run.model.name},
        "instructions_sha256": run.instructions_sha256,
        "started_at": run.started_at.isoformat(),
        "finished_at": run.finished_at.isoformat(),
        "summary": _metrics_to_json(compute_metrics(results)),
        "by_tag": {
            tag: _metrics_to_json(metrics)
            for tag, metrics in metrics_by_tag(results).items()
        },
        "failures": [
            {
                **_case_header(r.case),
                "expected": interpretation_to_json(r.case.expected),
                "actual": interpretation_to_json(r.actual),
                "mismatched_fields": list(r.mismatched_fields),
            }
            for r in results
            if r.status is CaseStatus.FAIL and r.actual is not None
        ],
        "errors": [
            {**_case_header(r.case), "error_type": r.error_type}
            for r in results
            if r.status is CaseStatus.ERROR
        ],
    }


def write_report(report: dict[str, Any], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )


def format_summary(report: dict[str, Any]) -> str:
    """Human-readable summary of a report for the terminal."""
    summary = report["summary"]
    lines = [
        f"Dataset {report['dataset']['version']} · model {report['model']['name']}",
        f"Cases: {summary['total']}  PASS {summary['passed']}  "
        f"FAIL {summary['failed']}  ERROR {summary['errored']}",
        f"Exact match: {_percent(summary['exact_match_rate'])}",
        "Field accuracy:",
    ]
    for name, accuracy in summary["field_accuracy"].items():
        lines.append(
            f"  {name:<22} {_percent(accuracy['accuracy']):>7}"
            f"  ({accuracy['correct']}/{accuracy['total']})"
        )
    lines.append("Exact match by tag:")
    for tag, metrics in report["by_tag"].items():
        lines.append(
            f"  {tag:<22} {_percent(metrics['exact_match_rate']):>7}"
            f"  ({metrics['passed']}/{metrics['passed'] + metrics['failed']})"
        )
    return "\n".join(lines)


def _percent(rate: float | None) -> str:
    return "n/a" if rate is None else f"{rate:.1%}"
