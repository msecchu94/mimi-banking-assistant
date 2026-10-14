from uuid import UUID

from mimi.application.repositories import AccountRepository
from mimi.domain.entities import Account


class GetAccountBalances:
    """Return the customer's accounts with their persisted balances.

    Balances are returned as stored: never converted or aggregated. A customer
    without accounts yields an empty list.
    """

    def __init__(self, accounts: AccountRepository) -> None:
        self._accounts = accounts

    def execute(self, customer_id: UUID) -> list[Account]:
        return self._accounts.list_by_customer(customer_id)
