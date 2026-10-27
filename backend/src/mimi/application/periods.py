"""Resolution of symbolic period references to concrete calendar periods."""

from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

from mimi.application.interpretation import (
    MIN_CALENDAR_YEAR,
    CalendarMonth,
    PeriodReference,
    TemporalReference,
)
from mimi.application.use_cases.analyze_expenses import Period

# The period immediately preceding each current period at the same scale.
_PREVIOUS: dict[PeriodReference, PeriodReference] = {
    PeriodReference.TODAY: PeriodReference.YESTERDAY,
    PeriodReference.CURRENT_WEEK: PeriodReference.PREVIOUS_WEEK,
    PeriodReference.CURRENT_MONTH: PeriodReference.PREVIOUS_MONTH,
}
_CURRENT = {previous: current for current, previous in _PREVIOUS.items()}


def previous_counterpart(reference: TemporalReference) -> TemporalReference | None:
    """Return the period preceding ``reference`` at the same scale, if defined.

    A calendar month is preceded by the month before it; a month without a
    year has no counterpart until it is anchored.
    """
    if isinstance(reference, CalendarMonth):
        if reference.year is None:
            return None
        if reference.month == 1:
            if reference.year == MIN_CALENDAR_YEAR:
                return None
            return CalendarMonth(12, reference.year - 1)
        return CalendarMonth(reference.month - 1, reference.year)
    return _PREVIOUS.get(reference)


def current_counterpart(reference: TemporalReference) -> TemporalReference | None:
    """Return the current period that ``reference`` is compared with, if defined.

    A calendar month is compared with the current month.
    """
    if isinstance(reference, CalendarMonth):
        return PeriodReference.CURRENT_MONTH
    return _CURRENT.get(reference)


def anchor(
    reference: TemporalReference, now: datetime, tz: ZoneInfo
) -> TemporalReference:
    """Return ``reference`` with any calendar month given a year.

    A month without a year is the latest such month that does not start after
    the month of ``now`` in ``tz``. Other references are returned unchanged.
    """
    if not isinstance(reference, CalendarMonth) or reference.year is not None:
        return reference
    return CalendarMonth(
        reference.month, _anchored_year(reference.month, _local_today(now, tz))
    )


def is_future(reference: TemporalReference, now: datetime, tz: ZoneInfo) -> bool:
    """Whether ``reference`` starts after ``now``; only a calendar month with a
    later year or month can."""
    return resolve_period(reference, now, tz).start > now


def resolve_period(reference: TemporalReference, now: datetime, tz: ZoneInfo) -> Period:
    """Resolve ``reference`` to a whole calendar period in ``tz``.

    Symbolic periods contain or precede ``now``; a calendar month without a
    year is anchored first. Periods are half-open and start at local midnight;
    weeks are ISO weeks starting on Monday and months are full calendar
    months. ``now`` must be timezone-aware.
    """
    today = _local_today(now, tz)
    if isinstance(reference, CalendarMonth):
        year = reference.year
        if year is None:
            year = _anchored_year(reference.month, today)
        start = date(year, reference.month, 1)
        return Period(_midnight(start, tz), _midnight(_next_month(start), tz))
    match reference:
        case PeriodReference.TODAY:
            start, end = today, today + timedelta(days=1)
        case PeriodReference.YESTERDAY:
            start, end = today - timedelta(days=1), today
        case PeriodReference.CURRENT_WEEK:
            start = today - timedelta(days=today.weekday())
            end = start + timedelta(weeks=1)
        case PeriodReference.PREVIOUS_WEEK:
            end = today - timedelta(days=today.weekday())
            start = end - timedelta(weeks=1)
        case PeriodReference.CURRENT_MONTH:
            start = today.replace(day=1)
            end = _next_month(start)
        case PeriodReference.PREVIOUS_MONTH:
            end = today.replace(day=1)
            start = (end - timedelta(days=1)).replace(day=1)
    return Period(_midnight(start, tz), _midnight(end, tz))


def _anchored_year(month: int, today: date) -> int:
    """The year of the latest ``month`` not starting after ``today``'s month."""
    return today.year if month <= today.month else today.year - 1


def _local_today(now: datetime, tz: ZoneInfo) -> date:
    if now.utcoffset() is None:
        raise ValueError("now must be timezone-aware")
    return now.astimezone(tz).date()


def _next_month(first_day: date) -> date:
    if first_day.month == 12:
        return first_day.replace(year=first_day.year + 1, month=1)
    return first_day.replace(month=first_day.month + 1)


def _midnight(day: date, tz: ZoneInfo) -> datetime:
    return datetime.combine(day, time.min, tzinfo=tz)
