from datetime import datetime
from uuid import UUID

from mimi.application.repositories import TransactionQuery, TransactionRepository
from mimi.domain.entities import Transaction


class GetTransactions:
    """Return the customer's transactions matching the query, newest first.

    An invalid query is a caller bug and raises ``ValueError``. A query that
    matches nothing yields an empty list.
    """

    def __init__(self, transactions: TransactionRepository) -> None:
        self._transactions = transactions

    def execute(self, customer_id: UUID, query: TransactionQuery) -> list[Transaction]:
        _validate(query)
        return self._transactions.list_by_customer(customer_id, query)


def _validate(query: TransactionQuery) -> None:
    _require_aware("occurred_from", query.occurred_from)
    _require_aware("occurred_to", query.occurred_to)
    if (
        query.occurred_from is not None
        and query.occurred_to is not None
        and query.occurred_from > query.occurred_to
    ):
        raise ValueError("occurred_from must not be after occurred_to")
    if query.limit is not None and query.limit < 1:
        raise ValueError("limit must be at least 1")


def _require_aware(field: str, value: datetime | None) -> None:
    if value is not None and value.utcoffset() is None:
        raise ValueError(f"{field} must be timezone-aware")
