"""Resolution of symbolic period references to concrete calendar periods."""

from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

from mimi.application.interpretation import PeriodReference
from mimi.application.use_cases.analyze_expenses import Period

# The period immediately preceding each current period at the same scale.
_PREVIOUS: dict[PeriodReference, PeriodReference] = {
    PeriodReference.TODAY: PeriodReference.YESTERDAY,
    PeriodReference.CURRENT_WEEK: PeriodReference.PREVIOUS_WEEK,
    PeriodReference.CURRENT_MONTH: PeriodReference.PREVIOUS_MONTH,
}
_CURRENT = {previous: current for current, previous in _PREVIOUS.items()}


def previous_counterpart(reference: PeriodReference) -> PeriodReference | None:
    """Return the period preceding ``reference`` at the same scale, if defined."""
    return _PREVIOUS.get(reference)


def current_counterpart(reference: PeriodReference) -> PeriodReference | None:
    """Return the current period that ``reference`` precedes, if defined."""
    return _CURRENT.get(reference)


def resolve_period(reference: PeriodReference, now: datetime, tz: ZoneInfo) -> Period:
    """Resolve ``reference`` to a whole calendar period containing or preceding
    ``now`` in ``tz``.

    Periods are half-open and start at local midnight; weeks are ISO weeks
    starting on Monday and months are full calendar months. ``now`` must be
    timezone-aware.
    """
    if now.utcoffset() is None:
        raise ValueError("now must be timezone-aware")
    today = now.astimezone(tz).date()
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


def _next_month(first_day: date) -> date:
    if first_day.month == 12:
        return first_day.replace(year=first_day.year + 1, month=1)
    return first_day.replace(month=first_day.month + 1)


def _midnight(day: date, tz: ZoneInfo) -> datetime:
    return datetime.combine(day, time.min, tzinfo=tz)
