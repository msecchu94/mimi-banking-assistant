import json
from decimal import Decimal
from pathlib import Path
from typing import Any

import pytest
from pydantic import BaseModel, SecretStr

import mimi.evaluation.__main__ as runner
from mimi.application.errors import LLMInvalidResponseError, LLMUnavailableError
from mimi.application.interpretation import (
    FollowUp,
    Intent,
    Interpretation,
    PeriodReference,
    RelativePeriod,
)
from mimi.config import LLMProviderName, Settings
from mimi.domain.enums import Currency, TransactionCategory
from mimi.evaluation.interpretation import (
    CaseResult,
    CaseStatus,
    DatasetError,
    EvaluationCase,
    ModelInfo,
    build_report,
    compute_metrics,
    interpretation_to_json,
    load_dataset,
    metrics_by_tag,
    mismatched_fields,
    run_evaluation,
)

EMPTY_OUTPUT: dict[str, Any] = {
    "intent": "UNKNOWN",
    "amount": None,
    "currency": None,
    "beneficiary_reference": None,
    "card_reference": None,
    "category": None,
    "transaction_type": None,
    "period": None,
    "comparison_period": None,
    "relative_period": None,
}

MODEL = ModelInfo(provider="fake", name="fake-model")


class ScriptedLLMProvider:
    """Returns a canned model output, or raises, per input message."""

    def __init__(self, script: dict[str, dict[str, Any] | Exception]) -> None:
        self._script = script
        self.instructions: list[str] = []

    def generate_structured[T: BaseModel](
        self, *, instructions: str, input_text: str, output_type: type[T]
    ) -> T:
        self.instructions.append(instructions)
        outcome = self._script[input_text]
        if isinstance(outcome, Exception):
            raise outcome
        return output_type.model_validate({**EMPTY_OUTPUT, **outcome})


def case_line(**overrides: Any) -> dict[str, Any]:
    line: dict[str, Any] = {
        "id": "transfer-01",
        "message": "Send 25000 to Laura",
        "tags": ["en", "transfer"],
        "expected": {
            "intent": "TRANSFER_MONEY",
            "amount": "25000",
            "beneficiary_reference": "Laura",
        },
    }
    return {**line, **overrides}


def write_dataset(
    tmp_path: Path, lines: list[dict[str, Any] | str], name: str = "cases.v3.jsonl"
) -> Path:
    path = tmp_path / name
    path.write_text(
        "\n".join(x if isinstance(x, str) else json.dumps(x) for x in lines) + "\n",
        encoding="utf-8",
    )
    return path


def make_case(
    expected: Interpretation, tags: tuple[str, ...] = ("en",), id: str = "c"
) -> EvaluationCase:
    return EvaluationCase(id=id, message=id, tags=tags, expected=expected)


def result(
    expected: Interpretation,
    actual: Interpretation | FollowUp | None,
    tags: tuple[str, ...] = ("en",),
) -> CaseResult:
    case = make_case(expected, tags)
    if actual is None:
        return CaseResult(case=case, status=CaseStatus.ERROR, error_type="E")
    mismatches = mismatched_fields(expected, actual)
    status = CaseStatus.FAIL if mismatches else CaseStatus.PASS
    return CaseResult(
        case=case, status=status, actual=actual, mismatched_fields=mismatches
    )


# Dataset loading


def test_loads_cases_as_expected_interpretations(tmp_path: Path) -> None:
    second = case_line(
        id="compare-01",
        message="This month vs last month",
        tags=["en", "comparison"],
        expected={
            "intent": "COMPARE_EXPENSES",
            "period": "CURRENT_MONTH",
            "comparison_period": "PREVIOUS_MONTH",
        },
        note="free text",
    )
    path = write_dataset(tmp_path, [case_line(), "", second])

    dataset = load_dataset(path)

    assert dataset.version == "v3"
    assert len(dataset.sha256) == 64
    first, compare = dataset.cases
    assert first == EvaluationCase(
        id="transfer-01",
        message="Send 25000 to Laura",
        tags=("en", "transfer"),
        expected=Interpretation(
            intent=Intent.TRANSFER_MONEY,
            amount=Decimal("25000"),
            beneficiary_reference="Laura",
        ),
    )
    assert compare.expected == Interpretation(
        intent=Intent.COMPARE_EXPENSES,
        period=PeriodReference.CURRENT_MONTH,
        comparison_period=PeriodReference.PREVIOUS_MONTH,
    )


def test_loads_flagged_fields_as_sets(tmp_path: Path) -> None:
    line = case_line(
        expected={
            "intent": "TRANSFER_MONEY",
            "amount": "100",
            "unsupported_fields": ["currency"],
            "invalid_fields": ["beneficiary_reference"],
        }
    )

    [case] = load_dataset(write_dataset(tmp_path, [line])).cases

    assert case.expected.unsupported_fields == frozenset({"currency"})
    assert case.expected.invalid_fields == frozenset({"beneficiary_reference"})


def test_dataset_hash_changes_when_content_changes(tmp_path: Path) -> None:
    path = write_dataset(tmp_path, [case_line()])
    before = load_dataset(path).sha256

    write_dataset(tmp_path, [case_line(message="Send 25000 to Laura!")])

    assert load_dataset(path).sha256 != before


@pytest.mark.parametrize(
    "line",
    [
        "{not json",
        case_line(extra="x"),
        case_line(expected={"intent": "TRANSFER_FUNDS"}),
        case_line(expected={"intent": "TRANSFER_MONEY", "currency": "EUR"}),
        case_line(expected={"intent": "TRANSFER_MONEY", "unknown_field": "x"}),
        case_line(expected={"intent": "TRANSFER_MONEY", "amount": "abc"}),
        case_line(expected={"intent": "TRANSFER_MONEY", "amount": "0"}),
        case_line(expected={"intent": "TRANSFER_MONEY", "amount": "-5"}),
        case_line(expected={"intent": "TRANSFER_MONEY", "amount": "NaN"}),
        case_line(expected={"intent": "TRANSFER_MONEY", "amount": 25000.5}),
        case_line(expected={"intent": "GET_BALANCE", "period": "TODAY"}),
        case_line(expected={"intent": "GET_BALANCE", "unsupported_fields": ["period"]}),
        case_line(
            expected={
                "intent": "TRANSFER_MONEY",
                "amount": "5",
                "unsupported_fields": ["amount"],
            }
        ),
        case_line(id=""),
        case_line(id=" padded "),
        case_line(message="   "),
        case_line(tags=[]),
        case_line(tags=["en", "en"]),
        case_line(tags=["English"]),
        case_line(tags=["two words"]),
        case_line(tags=[""]),
        case_line(expected={}),
    ],
)
def test_rejects_invalid_cases_with_their_line_number(
    tmp_path: Path, line: dict[str, Any] | str
) -> None:
    path = write_dataset(tmp_path, [case_line(id="valid-01"), line])

    with pytest.raises(DatasetError, match=r"cases\.v3\.jsonl:2:"):
        load_dataset(path)


def test_rejects_duplicate_ids(tmp_path: Path) -> None:
    path = write_dataset(tmp_path, [case_line(), case_line()])

    with pytest.raises(DatasetError, match="duplicate id 'transfer-01'"):
        load_dataset(path)


def test_accepts_new_tags_without_registration(tmp_path: Path) -> None:
    path = write_dataset(tmp_path, [case_line(tags=["brand-new-tag-2"])])

    [case] = load_dataset(path).cases

    assert case.tags == ("brand-new-tag-2",)


@pytest.mark.parametrize("name", ["cases.jsonl", "cases.v1.json", "cases.vx.jsonl"])
def test_requires_a_versioned_file_name(tmp_path: Path, name: str) -> None:
    path = write_dataset(tmp_path, [case_line()], name=name)

    with pytest.raises(DatasetError, match="v<N>"):
        load_dataset(path)


def test_rejects_empty_and_missing_datasets(tmp_path: Path) -> None:
    with pytest.raises(DatasetError, match="no cases"):
        load_dataset(write_dataset(tmp_path, [""]))
    with pytest.raises(DatasetError, match="cannot be read"):
        load_dataset(tmp_path / "missing.v1.jsonl")


def test_committed_dataset_is_valid() -> None:
    dataset = load_dataset(runner.DEFAULT_DATASET)

    assert dataset.version == "v1"
    assert len(dataset.cases) >= 60
    assert {c.expected.intent for c in dataset.cases} == set(Intent)


# Scoring


def test_identical_interpretations_have_no_mismatches() -> None:
    expected = Interpretation(
        intent=Intent.TRANSFER_MONEY,
        amount=Decimal("5000"),
        currency=Currency.USD,
        beneficiary_reference="Laura",
        unsupported_fields=frozenset({"x", "y"}),
    )
    actual = Interpretation(
        intent=Intent.TRANSFER_MONEY,
        amount=Decimal("5000.00"),
        currency=Currency.USD,
        beneficiary_reference="Laura",
        unsupported_fields=frozenset({"y", "x"}),
    )

    assert mismatched_fields(expected, actual) == ()


def test_references_match_after_normalization() -> None:
    expected = Interpretation(intent=Intent.FREEZE_CARD, card_reference="my Visa")

    assert (
        mismatched_fields(
            expected,
            Interpretation(intent=Intent.FREEZE_CARD, card_reference="  MY \t visa "),
        )
        == ()
    )
    assert mismatched_fields(
        expected, Interpretation(intent=Intent.FREEZE_CARD, card_reference="Visa")
    ) == ("card_reference",)


def test_reports_every_mismatched_field() -> None:
    expected = Interpretation(
        intent=Intent.TRANSFER_MONEY, amount=Decimal("5000"), currency=Currency.ARS
    )
    actual = Interpretation(
        intent=Intent.TRANSFER_MONEY,
        amount=Decimal("500"),
        unsupported_fields=frozenset({"currency"}),
    )

    assert mismatched_fields(expected, actual) == (
        "amount",
        "currency",
        "unsupported_fields",
    )


def test_follow_up_mismatches_intent_and_every_differing_value() -> None:
    expected = Interpretation(
        intent=Intent.ANALYZE_EXPENSES,
        category=TransactionCategory.DINING,
        period=PeriodReference.PREVIOUS_MONTH,
    )
    actual = FollowUp(
        category=TransactionCategory.DINING, relative_period=RelativePeriod.PREVIOUS
    )

    assert mismatched_fields(expected, actual) == ("intent", "period")


def test_follow_up_is_serialized_with_a_marker_instead_of_an_intent() -> None:
    follow_up = FollowUp(
        category=TransactionCategory.DINING,
        relative_period=RelativePeriod.PREVIOUS,
        unsupported_fields=frozenset({"transaction_type"}),
    )

    assert interpretation_to_json(follow_up) == {
        "follow_up": True,
        "category": "DINING",
        "relative_period": "PREVIOUS",
        "unsupported_fields": ["transaction_type"],
    }


# Running cases


def test_classifies_pass_fail_and_provider_errors(tmp_path: Path) -> None:
    path = write_dataset(
        tmp_path,
        [
            case_line(id="pass", message="pass"),
            case_line(id="fail", message="fail"),
            case_line(id="unavailable", message="unavailable"),
            case_line(id="invalid", message="invalid"),
        ],
    )
    transfer = {"intent": "TRANSFER_MONEY", "beneficiary_reference": "Laura"}
    llm = ScriptedLLMProvider(
        {
            "pass": {**transfer, "amount": "25000"},
            "fail": {**transfer, "amount": "2500"},
            "unavailable": LLMUnavailableError(),
            "invalid": LLMInvalidResponseError(),
        }
    )

    run = run_evaluation(load_dataset(path), llm, MODEL)

    statuses = {r.case.id: r.status for r in run.results}
    assert statuses == {
        "pass": CaseStatus.PASS,
        "fail": CaseStatus.FAIL,
        "unavailable": CaseStatus.ERROR,
        "invalid": CaseStatus.ERROR,
    }
    fail = next(r for r in run.results if r.case.id == "fail")
    assert fail.mismatched_fields == ("amount",)
    errors = {r.case.id: r.error_type for r in run.results if r.actual is None}
    assert errors == {
        "unavailable": "LLMUnavailableError",
        "invalid": "LLMInvalidResponseError",
    }


def test_unexpected_exceptions_abort_the_run(tmp_path: Path) -> None:
    path = write_dataset(tmp_path, [case_line()])
    llm = ScriptedLLMProvider({"Send 25000 to Laura": RuntimeError("rejected")})

    with pytest.raises(RuntimeError, match="rejected"):
        run_evaluation(load_dataset(path), llm, MODEL)


def test_reports_progress_and_fingerprints_instructions(tmp_path: Path) -> None:
    path = write_dataset(tmp_path, [case_line()])
    llm = ScriptedLLMProvider({"Send 25000 to Laura": {"intent": "UNKNOWN"}})
    seen: list[CaseResult] = []

    run = run_evaluation(load_dataset(path), llm, MODEL, on_result=seen.append)

    assert seen == list(run.results)
    assert run.instructions_sha256 is not None
    assert len(run.instructions_sha256) == 64
    assert run.started_at.tzinfo is not None
    assert run.finished_at >= run.started_at


# Metrics


def test_follow_up_results_fail_and_count_against_intent_accuracy(
    tmp_path: Path,
) -> None:
    path = write_dataset(
        tmp_path,
        [
            case_line(
                id="context",
                message="¿Y el mes pasado?",
                tags=["es", "context-dependent"],
                expected={"intent": "UNKNOWN"},
            )
        ],
    )
    llm = ScriptedLLMProvider(
        {"¿Y el mes pasado?": {"intent": "FOLLOW_UP", "period": "PREVIOUS_MONTH"}}
    )

    run = run_evaluation(load_dataset(path), llm, MODEL)

    [case_result] = run.results
    assert case_result.status is CaseStatus.FAIL
    assert case_result.actual == FollowUp(period=PeriodReference.PREVIOUS_MONTH)
    assert case_result.mismatched_fields == ("intent", "period")
    metrics = compute_metrics(run.results)
    assert metrics.field_accuracy["intent"].correct == 0
    assert metrics.field_accuracy["period"].correct == 0
    assert metrics.field_accuracy["period"].total == 1
    [failure] = build_report(run)["failures"]
    assert failure["actual"] == {"follow_up": True, "period": "PREVIOUS_MONTH"}


def test_errors_are_counted_but_excluded_from_quality_metrics() -> None:
    expected = Interpretation(intent=Intent.GET_BALANCE)
    results = [
        result(expected, expected),
        result(expected, Interpretation(intent=Intent.UNKNOWN)),
        result(expected, None),
    ]

    metrics = compute_metrics(results)

    assert (metrics.total, metrics.passed, metrics.failed, metrics.errored) == (
        3,
        1,
        1,
        1,
    )
    assert metrics.exact_match_rate == 0.5
    intent = metrics.field_accuracy["intent"]
    assert (intent.correct, intent.total, intent.accuracy) == (1, 2, 0.5)


def test_field_accuracy_counts_only_cases_where_the_field_is_set() -> None:
    transfer = Interpretation(
        intent=Intent.TRANSFER_MONEY, amount=Decimal("100"), currency=Currency.ARS
    )
    results = [
        result(transfer, transfer),
        result(transfer, Interpretation(intent=Intent.TRANSFER_MONEY)),
        result(
            Interpretation(intent=Intent.GET_BALANCE),
            Interpretation(intent=Intent.TRANSFER_MONEY, amount=Decimal("5")),
        ),
        result(
            Interpretation(intent=Intent.GET_BALANCE),
            Interpretation(intent=Intent.GET_BALANCE),
        ),
    ]

    accuracy = compute_metrics(results).field_accuracy

    assert (accuracy["amount"].correct, accuracy["amount"].total) == (1, 3)
    assert (accuracy["currency"].correct, accuracy["currency"].total) == (1, 2)
    assert (accuracy["intent"].correct, accuracy["intent"].total) == (3, 4)
    assert accuracy["period"].total == 0
    assert accuracy["period"].accuracy is None


def test_rates_are_undefined_without_scored_cases() -> None:
    metrics = compute_metrics([result(Interpretation(intent=Intent.CANCEL), None)])

    assert metrics.exact_match_rate is None
    assert metrics.field_accuracy["intent"].accuracy is None


def test_metrics_are_computed_per_tag() -> None:
    balance = Interpretation(intent=Intent.GET_BALANCE)
    results = [
        result(balance, balance, tags=("en", "balance")),
        result(balance, Interpretation(intent=Intent.UNKNOWN), tags=("es", "balance")),
    ]

    by_tag = metrics_by_tag(results)

    assert list(by_tag) == ["balance", "en", "es"]
    assert by_tag["balance"].exact_match_rate == 0.5
    assert by_tag["en"].exact_match_rate == 1.0
    assert by_tag["es"].exact_match_rate == 0.0


# Report and runner


def test_report_describes_run_metrics_failures_and_errors(tmp_path: Path) -> None:
    path = write_dataset(
        tmp_path,
        [
            case_line(id="pass", message="pass"),
            case_line(id="fail", message="fail", tags=["es"]),
            case_line(id="error", message="error"),
        ],
    )
    llm = ScriptedLLMProvider(
        {
            "pass": {
                "intent": "TRANSFER_MONEY",
                "amount": "25000",
                "beneficiary_reference": "Laura",
            },
            "fail": {
                "intent": "TRANSFER_MONEY",
                "amount": "25000.5",
                "currency": "UNSUPPORTED",
            },
            "error": LLMUnavailableError("secret provider detail"),
        }
    )

    report = build_report(run_evaluation(load_dataset(path), llm, MODEL))
    # Round-trips through JSON: no Decimal, enum or datetime objects remain.
    report = json.loads(json.dumps(report))

    assert report["report_schema_version"] == 2
    assert report["dataset"]["version"] == "v3"
    assert report["dataset"]["case_count"] == 3
    assert report["model"] == {"provider": "fake", "name": "fake-model"}
    assert len(report["instructions_sha256"]) == 64
    summary = report["summary"]
    assert (summary["passed"], summary["failed"], summary["errored"]) == (1, 1, 1)
    assert summary["exact_match_rate"] == 0.5
    assert report["by_tag"]["es"]["exact_match_rate"] == 0.0
    assert report["failures"] == [
        {
            "id": "fail",
            "message": "fail",
            "tags": ["es"],
            "expected": {
                "intent": "TRANSFER_MONEY",
                "amount": "25000",
                "beneficiary_reference": "Laura",
            },
            "actual": {
                "intent": "TRANSFER_MONEY",
                "amount": "25000.5",
                "unsupported_fields": ["currency"],
            },
            "mismatched_fields": [
                "amount",
                "beneficiary_reference",
                "unsupported_fields",
            ],
        }
    ]
    assert report["errors"] == [
        {
            "id": "error",
            "message": "error",
            "tags": ["en", "transfer"],
            "error_type": "LLMUnavailableError",
        }
    ]
    assert "secret provider detail" not in json.dumps(report)


def test_runner_writes_a_report_with_the_configured_provider(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    settings = Settings(
        _env_file=None,
        database_url=SecretStr("postgresql+psycopg://mimi:s3cret@localhost:5432/mimi"),
        llm_provider=LLMProviderName.OPENAI,
        llm_model="gpt-test",
    )
    llm = ScriptedLLMProvider(
        {
            "Send 25000 to Laura": {
                "intent": "TRANSFER_MONEY",
                "amount": "25000",
                "beneficiary_reference": "Laura",
            }
        }
    )
    monkeypatch.setattr(runner, "get_settings", lambda: settings)
    monkeypatch.setattr(runner, "build_llm_provider", lambda settings: llm)
    dataset = write_dataset(tmp_path, [case_line()])
    output = tmp_path / "out" / "report.json"

    code = runner.main(["--dataset", str(dataset), "--output", str(output)])

    assert code == 0
    report = json.loads(output.read_text(encoding="utf-8"))
    assert report["model"] == {"provider": "openai", "name": "gpt-test"}
    assert report["summary"]["passed"] == 1
    assert "Exact match: 100.0%" in capsys.readouterr().out


def test_runner_rejects_an_invalid_dataset_before_building_the_provider(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    def fail() -> None:
        raise AssertionError("settings must not be loaded")

    monkeypatch.setattr(runner, "get_settings", fail)
    dataset = write_dataset(tmp_path, ["{not json"])

    assert runner.main(["--dataset", str(dataset)]) == 2


def test_runner_reports_invalid_configuration(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    def build(settings: object) -> None:
        raise ValueError("MIMI_LLM_MODEL is required to build the LLM provider")

    monkeypatch.setattr(runner, "get_settings", lambda: object())
    monkeypatch.setattr(runner, "build_llm_provider", build)
    dataset = write_dataset(tmp_path, [case_line()])

    assert runner.main(["--dataset", str(dataset)]) == 2
