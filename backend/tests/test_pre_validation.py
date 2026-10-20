from dataclasses import dataclass, field, replace
from decimal import Decimal
from typing import Any, NoReturn
from uuid import UUID, uuid4

import pytest

from mimi.application.conversation_results import (
    AwaitingConfirmationResult,
    PreValidationFailedResult,
)
from mimi.application.errors import (
    AccountNotFoundError,
    ApplicationError,
    BeneficiaryNotFoundError,
    CardNotFoundError,
    InsufficientFundsError,
    InvalidAccountStateError,
    InvalidAmountError,
    InvalidCardStateError,
)
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingOperation,
    TransferOperationData,
    UnfreezeCardOperationData,
)
from mimi.application.pre_validation import pre_validate
from mimi.domain.entities import Account, Beneficiary, Card, Money
from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    Currency,
    PendingOperationType,
)

CUSTOMER_ID = uuid4()

ACCOUNT = Account(
    uuid4(),
    CUSTOMER_ID,
    "Cuenta principal",
    Money(Decimal("1000.00"), Currency.ARS),
    AccountStatus.ACTIVE,
)
LAURA = Beneficiary(uuid4(), CUSTOMER_ID, "Laura Gómez", "0000003100012345678901", None)
ACTIVE_CARD = Card(
    uuid4(), ACCOUNT.id, CardType.DEBIT, CardBrand.VISA, "4821", CardStatus.ACTIVE
)
FROZEN_CARD = replace(ACTIVE_CARD, id=uuid4(), status=CardStatus.FROZEN)


def refuse_write(*args: object) -> NoReturn:
    raise AssertionError("pre-validation must not write")


class Accounts:
    def __init__(self, accounts: list[Account]) -> None:
        self.accounts = accounts
        self.locked: list[UUID] = []

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        self.locked.append(account_id)
        return next(
            (
                a
                for a in self.accounts
                if a.id == account_id and a.customer_id == customer_id
            ),
            None,
        )

    def update_balance(self, account_id: UUID, balance: Money) -> None:
        refuse_write()


class Lookup[T]:
    def __init__(self, records: list[T]) -> None:
        self.records = records

    def get(self, customer_id: UUID, record_id: UUID) -> T | None:
        if customer_id != CUSTOMER_ID:
            return None
        return next(
            (r for r in self.records if getattr(r, "id", None) == record_id), None
        )

    def update_status(self, card_id: UUID, status: CardStatus) -> None:
        refuse_write()


@dataclass
class FakeRepositories:
    accounts: Any = field(default_factory=lambda: Accounts([ACCOUNT]))
    beneficiaries: Any = field(default_factory=lambda: Lookup([LAURA]))
    cards: Any = field(default_factory=lambda: Lookup([ACTIVE_CARD, FROZEN_CARD]))
    transactions: Any = None
    conversations: Any = None
    messages: Any = None


FIVE_HUNDRED = Money(Decimal("500.00"), Currency.ARS)


def transfer(
    amount: Money = FIVE_HUNDRED,
    *,
    source_account_id: UUID = ACCOUNT.id,
    beneficiary_id: UUID = LAURA.id,
) -> PendingOperation:
    return PendingOperation(
        PendingOperationType.TRANSFER,
        TransferOperationData(source_account_id, beneficiary_id, amount),
    )


def test_executable_transfer_awaits_confirmation_with_its_records() -> None:
    repositories = FakeRepositories()
    operation = transfer()

    result = pre_validate(repositories, CUSTOMER_ID, operation)

    assert result == AwaitingConfirmationResult(
        operation, source_account=ACCOUNT, beneficiary=LAURA
    )
    assert repositories.accounts.locked == [ACCOUNT.id]


def test_transfer_of_the_whole_balance_is_executable() -> None:
    result = pre_validate(
        FakeRepositories(),
        CUSTOMER_ID,
        transfer(Money(Decimal("1000.00"), Currency.ARS)),
    )

    assert isinstance(result, AwaitingConfirmationResult)


@pytest.mark.parametrize(
    ("repositories", "operation", "error"),
    [
        (FakeRepositories(), transfer(source_account_id=uuid4()), AccountNotFoundError),
        (
            FakeRepositories(),
            transfer(beneficiary_id=uuid4()),
            BeneficiaryNotFoundError,
        ),
        (
            FakeRepositories(
                accounts=Accounts([replace(ACCOUNT, status=AccountStatus.INACTIVE)])
            ),
            transfer(),
            InvalidAccountStateError,
        ),
        (
            FakeRepositories(),
            transfer(Money(Decimal("5.00"), Currency.USD)),
            InvalidAmountError,
        ),
        (
            FakeRepositories(),
            transfer(Money(Decimal("1000.01"), Currency.ARS)),
            InsufficientFundsError,
        ),
    ],
    ids=["account", "beneficiary", "inactive", "currency", "funds"],
)
def test_non_executable_transfer_fails_with_its_semantic_error(
    repositories: FakeRepositories,
    operation: PendingOperation,
    error: type[ApplicationError],
) -> None:
    result = pre_validate(repositories, CUSTOMER_ID, operation)

    assert isinstance(result, PreValidationFailedResult)
    assert result.operation == operation
    assert isinstance(result.error, error)


def test_records_of_another_customer_are_not_found() -> None:
    result = pre_validate(FakeRepositories(), uuid4(), transfer())

    assert isinstance(result, PreValidationFailedResult)
    assert isinstance(result.error, AccountNotFoundError)


@pytest.mark.parametrize(
    ("operation", "expected"),
    [
        (
            PendingOperation(
                PendingOperationType.FREEZE_CARD,
                FreezeCardOperationData(ACTIVE_CARD.id),
            ),
            ACTIVE_CARD,
        ),
        (
            PendingOperation(
                PendingOperationType.UNFREEZE_CARD,
                UnfreezeCardOperationData(FROZEN_CARD.id),
            ),
            FROZEN_CARD,
        ),
    ],
)
def test_valid_card_transition_awaits_confirmation(
    operation: PendingOperation, expected: Card
) -> None:
    result = pre_validate(FakeRepositories(), CUSTOMER_ID, operation)

    assert result == AwaitingConfirmationResult(operation, card=expected)


@pytest.mark.parametrize(
    ("operation", "error"),
    [
        (
            PendingOperation(
                PendingOperationType.FREEZE_CARD,
                FreezeCardOperationData(FROZEN_CARD.id),
            ),
            InvalidCardStateError,
        ),
        (
            PendingOperation(
                PendingOperationType.UNFREEZE_CARD,
                UnfreezeCardOperationData(ACTIVE_CARD.id),
            ),
            InvalidCardStateError,
        ),
        (
            PendingOperation(
                PendingOperationType.FREEZE_CARD, FreezeCardOperationData(uuid4())
            ),
            CardNotFoundError,
        ),
    ],
    ids=["already_frozen", "not_frozen", "unknown"],
)
def test_invalid_card_transition_fails_with_its_semantic_error(
    operation: PendingOperation, error: type[ApplicationError]
) -> None:
    result = pre_validate(FakeRepositories(), CUSTOMER_ID, operation)

    assert isinstance(result, PreValidationFailedResult)
    assert isinstance(result.error, error)


@pytest.mark.parametrize(
    "operation",
    [
        PendingOperation(
            PendingOperationType.TRANSFER,
            TransferOperationData(
                ACCOUNT.id, LAURA.id, unresolved_amount=Decimal("500")
            ),
        ),
        PendingOperation(PendingOperationType.FREEZE_CARD, FreezeCardOperationData()),
    ],
    ids=["unresolved_amount", "missing_card"],
)
def test_incomplete_operation_cannot_be_pre_validated(
    operation: PendingOperation,
) -> None:
    with pytest.raises(ValueError, match="complete"):
        pre_validate(FakeRepositories(), CUSTOMER_ID, operation)
