from datetime import UTC, datetime, timedelta, timezone
from zoneinfo import ZoneInfo

import pytest

from mimi.application.interpretation import PeriodReference
from mimi.application.periods import (
    current_counterpart,
    previous_counterpart,
    resolve_period,
)
from mimi.application.use_cases.analyze_expenses import Period

BUENOS_AIRES = ZoneInfo("America/Argentina/Buenos_Aires")

# Thursday 2026-10-15, 13:31 local time.
NOW = datetime(2026, 10, 15, 13, 31, tzinfo=BUENOS_AIRES)


def local(year: int, month: int, day: int) -> datetime:
    return datetime(year, month, day, tzinfo=BUENOS_AIRES)


@pytest.mark.parametrize(
    ("reference", "expected"),
    [
        (PeriodReference.TODAY, Period(local(2026, 10, 15), local(2026, 10, 16))),
        (PeriodReference.YESTERDAY, Period(local(2026, 10, 14), local(2026, 10, 15))),
        (
            PeriodReference.CURRENT_WEEK,
            Period(local(2026, 10, 12), local(2026, 10, 19)),
        ),
        (
            PeriodReference.PREVIOUS_WEEK,
            Period(local(2026, 10, 5), local(2026, 10, 12)),
        ),
        (
            PeriodReference.CURRENT_MONTH,
            Period(local(2026, 10, 1), local(2026, 11, 1)),
        ),
        (
            PeriodReference.PREVIOUS_MONTH,
            Period(local(2026, 9, 1), local(2026, 10, 1)),
        ),
    ],
)
def test_reference_resolves_to_whole_calendar_period(
    reference: PeriodReference, expected: Period
) -> None:
    assert resolve_period(reference, NOW, BUENOS_AIRES) == expected


def test_week_starts_on_monday() -> None:
    monday = datetime(2026, 10, 12, 0, 0, tzinfo=BUENOS_AIRES)
    sunday = datetime(2026, 10, 18, 23, 59, tzinfo=BUENOS_AIRES)
    expected = Period(local(2026, 10, 12), local(2026, 10, 19))

    assert resolve_period(PeriodReference.CURRENT_WEEK, monday, BUENOS_AIRES) == (
        expected
    )
    assert resolve_period(PeriodReference.CURRENT_WEEK, sunday, BUENOS_AIRES) == (
        expected
    )


def test_week_may_span_months_and_years() -> None:
    now = datetime(2027, 1, 1, 10, 0, tzinfo=BUENOS_AIRES)  # Friday

    assert resolve_period(PeriodReference.CURRENT_WEEK, now, BUENOS_AIRES) == Period(
        local(2026, 12, 28), local(2027, 1, 4)
    )
    assert resolve_period(PeriodReference.PREVIOUS_WEEK, now, BUENOS_AIRES) == Period(
        local(2026, 12, 21), local(2026, 12, 28)
    )


def test_months_roll_over_years() -> None:
    december = datetime(2026, 12, 31, 23, 0, tzinfo=BUENOS_AIRES)
    january = datetime(2027, 1, 1, 0, 0, tzinfo=BUENOS_AIRES)

    assert resolve_period(
        PeriodReference.CURRENT_MONTH, december, BUENOS_AIRES
    ) == Period(local(2026, 12, 1), local(2027, 1, 1))
    assert resolve_period(
        PeriodReference.PREVIOUS_MONTH, january, BUENOS_AIRES
    ) == Period(local(2026, 12, 1), local(2027, 1, 1))


def test_yesterday_rolls_over_month_start() -> None:
    now = datetime(2026, 3, 1, 9, 0, tzinfo=BUENOS_AIRES)

    assert resolve_period(PeriodReference.YESTERDAY, now, BUENOS_AIRES) == Period(
        local(2026, 2, 28), local(2026, 3, 1)
    )


def test_now_is_read_in_the_given_timezone() -> None:
    # 01:30 UTC on Nov 1st is still Oct 31st in Buenos Aires.
    now = datetime(2026, 11, 1, 1, 30, tzinfo=UTC)

    assert resolve_period(PeriodReference.TODAY, now, BUENOS_AIRES) == Period(
        local(2026, 10, 31), local(2026, 11, 1)
    )
    assert resolve_period(PeriodReference.CURRENT_MONTH, now, BUENOS_AIRES) == (
        Period(local(2026, 10, 1), local(2026, 11, 1))
    )


def test_periods_are_half_open_and_adjacent() -> None:
    current = resolve_period(PeriodReference.CURRENT_MONTH, NOW, BUENOS_AIRES)
    previous = resolve_period(PeriodReference.PREVIOUS_MONTH, NOW, BUENOS_AIRES)

    assert previous.end == current.start
    assert current.start.utcoffset() == timedelta(hours=-3)


def test_naive_now_is_rejected() -> None:
    with pytest.raises(ValueError, match="timezone-aware"):
        resolve_period(PeriodReference.TODAY, NOW.replace(tzinfo=None), BUENOS_AIRES)


def test_fixed_offset_now_is_accepted() -> None:
    now = datetime(2026, 10, 15, 18, 31, tzinfo=timezone(timedelta(hours=2)))

    assert resolve_period(PeriodReference.TODAY, now, BUENOS_AIRES) == Period(
        local(2026, 10, 15), local(2026, 10, 16)
    )


@pytest.mark.parametrize(
    ("current", "previous"),
    [
        (PeriodReference.TODAY, PeriodReference.YESTERDAY),
        (PeriodReference.CURRENT_WEEK, PeriodReference.PREVIOUS_WEEK),
        (PeriodReference.CURRENT_MONTH, PeriodReference.PREVIOUS_MONTH),
    ],
)
def test_counterparts_pair_current_and_previous_periods(
    current: PeriodReference, previous: PeriodReference
) -> None:
    assert previous_counterpart(current) is previous
    assert current_counterpart(previous) is current


@pytest.mark.parametrize(
    "reference",
    [
        PeriodReference.YESTERDAY,
        PeriodReference.PREVIOUS_WEEK,
        PeriodReference.PREVIOUS_MONTH,
    ],
)
def test_previous_periods_have_no_previous_counterpart(
    reference: PeriodReference,
) -> None:
    assert previous_counterpart(reference) is None


@pytest.mark.parametrize(
    "reference",
    [
        PeriodReference.TODAY,
        PeriodReference.CURRENT_WEEK,
        PeriodReference.CURRENT_MONTH,
    ],
)
def test_current_periods_have_no_current_counterpart(
    reference: PeriodReference,
) -> None:
    assert current_counterpart(reference) is None
