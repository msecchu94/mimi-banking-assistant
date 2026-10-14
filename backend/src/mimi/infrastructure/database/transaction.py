from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass

from sqlalchemy.orm import Session, sessionmaker

from mimi.application.repositories import (
    AccountRepository,
    BeneficiaryRepository,
    CardRepository,
    TransactionRepository,
    TransferRepository,
)
from mimi.infrastructure.database.repositories import (
    PostgresAccountRepository,
    PostgresBeneficiaryRepository,
    PostgresCardRepository,
    PostgresTransactionRepository,
    PostgresTransferRepository,
)


@dataclass(frozen=True)
class PostgresRepositories:
    """Repositories sharing one Session and therefore one database transaction."""

    accounts: AccountRepository
    cards: CardRepository
    beneficiaries: BeneficiaryRepository
    transactions: TransactionRepository
    transfers: TransferRepository


class PostgresTransactionScope:
    def __init__(self, session_factory: sessionmaker[Session]) -> None:
        self._session_factory = session_factory

    @contextmanager
    def begin(self) -> Iterator[PostgresRepositories]:
        """Commit on normal exit, roll back on exception, then close the session."""
        with self._session_factory.begin() as session:
            yield PostgresRepositories(
                accounts=PostgresAccountRepository(session),
                cards=PostgresCardRepository(session),
                beneficiaries=PostgresBeneficiaryRepository(session),
                transactions=PostgresTransactionRepository(session),
                transfers=PostgresTransferRepository(session),
            )
