from uuid import UUID

from mimi.application.repositories import TransactionQuery, TransactionScope
from mimi.application.use_cases.get_account_balances import GetAccountBalances
from mimi.application.use_cases.get_transactions import GetTransactions
from mimi.domain.entities import Account, Transaction


class AccountQueries:
    """Read-only access to a customer's persisted accounts and transactions,
    outside any conversation.

    Each query runs in its own transaction and returns data as stored.
    """

    def __init__(self, transaction_scope: TransactionScope) -> None:
        self._transaction_scope = transaction_scope

    def list_accounts(self, customer_id: UUID) -> list[Account]:
        with self._transaction_scope.begin() as repositories:
            return GetAccountBalances(repositories.accounts).execute(customer_id)

    def list_recent_transactions(
        self, customer_id: UUID, account_id: UUID | None, limit: int
    ) -> list[Transaction]:
        """Return the newest ``limit`` transactions, of ``account_id`` when
        given. An account the customer does not own matches nothing."""
        query = TransactionQuery(account_id=account_id, limit=limit)
        with self._transaction_scope.begin() as repositories:
            return GetTransactions(repositories.transactions).execute(
                customer_id, query
            )
