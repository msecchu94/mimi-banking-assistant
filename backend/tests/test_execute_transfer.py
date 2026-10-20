from dataclasses import replace
from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest

from mimi.application.errors import (
    AccountNotFoundError,
    ApplicationError,
    BeneficiaryNotFoundError,
    BusinessRuleViolationError,
    ConflictError,
    InsufficientFundsError,
    InvalidAccountStateError,
    InvalidAmountError,
    NotFoundError,
)
from mimi.application.use_cases.execute_transfer import ExecuteTransfer
from mimi.domain.entities import Account, Beneficiary, Money, Transaction, Transfer
from mimi.domain.enums import (
    AccountStatus,
    Currency,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()
NOW = datetime(2026, 10, 9, 16, 30, tzinfo=UTC)
OPENING_BALANCE = Money(Decimal("150000.50"), Currency.ARS)


class FakeAccountRepository:
    def __init__(self, accounts: list[Account]) -> None:
        self._accounts = {account.id: account for account in accounts}
        self.locked_reads: list[UUID] = []
        self.balance_updates: list[tuple[UUID, Money]] = []

    def list_by_customer(self, customer_id: UUID) -> list[Account]:
        raise AssertionError("transfer execution must not list accounts")

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        self.locked_reads.append(account_id)
        account = self._accounts.get(account_id)
        if account is None or account.customer_id != customer_id:
            return None
        return account

    def update_balance(self, account_id: UUID, balance: Money) -> None:
        self.balance_updates.append((account_id, balance))
        self._accounts[account_id] = replace(
            self._accounts[account_id], balance=balance
        )

    def stored(self, account_id: UUID) -> Account:
        return self._accounts[account_id]


class FakeBeneficiaryRepository:
    def __init__(self, beneficiaries: list[Beneficiary]) -> None:
        self._beneficiaries = {b.id: b for b in beneficiaries}
        self.reads = 0

    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]:
        raise AssertionError("transfer execution must not list beneficiaries")

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None:
        self.reads += 1
        beneficiary = self._beneficiaries.get(beneficiary_id)
        if beneficiary is None or beneficiary.customer_id != customer_id:
            return None
        return beneficiary


class FakeTransferRepository:
    def __init__(self) -> None:
        self.added: list[tuple[Transfer, Transaction | None]] = []

    def add(self, transfer: Transfer, transaction: Transaction | None) -> None:
        self.added.append((transfer, transaction))


def make_account(
    *,
    balance: Money = OPENING_BALANCE,
    status: AccountStatus = AccountStatus.ACTIVE,
    customer_id: UUID = CUSTOMER_ID,
) -> Account:
    return Account(
        id=uuid4(),
        customer_id=customer_id,
        name="Caja de ahorro",
        balance=balance,
        status=status,
    )


def make_beneficiary(*, customer_id: UUID = CUSTOMER_ID) -> Beneficiary:
    return Beneficiary(
        id=uuid4(),
        customer_id=customer_id,
        name="Laura",
        account_reference="0000003100012345678901",
        bank_name=None,
    )


class Harness:
    def __init__(
        self,
        account: Account,
        beneficiary: Beneficiary,
        clock_value: datetime = NOW,
    ) -> None:
        self.account = account
        self.beneficiary = beneficiary
        self.accounts = FakeAccountRepository([account])
        self.beneficiaries = FakeBeneficiaryRepository([beneficiary])
        self.transfers = FakeTransferRepository()
        self.use_case = ExecuteTransfer(
            self.accounts, self.beneficiaries, self.transfers, lambda: clock_value
        )

    def execute(
        self,
        amount: Money,
        *,
        source_account_id: UUID | None = None,
        beneficiary_id: UUID | None = None,
    ) -> Transfer:
        return self.use_case.execute(
            customer_id=CUSTOMER_ID,
            source_account_id=source_account_id or self.account.id,
            beneficiary_id=beneficiary_id or self.beneficiary.id,
            amount=amount,
        )

    def assert_no_writes(self) -> None:
        assert self.accounts.balance_updates == []
        assert self.transfers.added == []
        assert self.accounts.stored(self.account.id) == self.account


def ars(amount: str) -> Money:
    return Money(Decimal(amount), Currency.ARS)


@pytest.fixture
def harness() -> Harness:
    return Harness(make_account(), make_beneficiary())


def test_executes_completed_transfer(harness: Harness) -> None:
    transfer = harness.execute(ars("25000.00"))

    assert transfer == Transfer(
        id=transfer.id,
        source_account_id=harness.account.id,
        beneficiary_id=harness.beneficiary.id,
        amount=ars("25000.00"),
        status=TransferStatus.COMPLETED,
        created_at=NOW,
        executed_at=NOW,
    )


def test_persists_transfer_with_linked_debit_transaction(harness: Harness) -> None:
    transfer = harness.execute(ars("25000.00"))

    [(added_transfer, transaction)] = harness.transfers.added
    assert added_transfer == transfer
    assert transaction is not None
    assert transaction == Transaction(
        id=transaction.id,
        account_id=harness.account.id,
        amount=ars("25000.00"),
        type=TransactionType.DEBIT,
        category=TransactionCategory.TRANSFER,
        description="Transfer to Laura",
        occurred_at=NOW,
        transfer_id=transfer.id,
    )


def test_debits_source_account_balance(harness: Harness) -> None:
    harness.execute(ars("25000.00"))

    assert harness.accounts.balance_updates == [(harness.account.id, ars("125000.50"))]
    assert harness.accounts.stored(harness.account.id).balance == ars("125000.50")


def test_locks_source_account_before_validating_balance(harness: Harness) -> None:
    harness.execute(ars("25000.00"))

    assert harness.accounts.locked_reads == [harness.account.id]


def test_allows_transferring_the_entire_balance(harness: Harness) -> None:
    harness.execute(ars("150000.50"))

    assert harness.accounts.stored(harness.account.id).balance == ars("0.00")


def test_accepts_amount_with_trailing_zero_decimals(harness: Harness) -> None:
    harness.execute(ars("100.000"))

    assert harness.accounts.stored(harness.account.id).balance == ars("149900.50")


@pytest.mark.parametrize(
    "amount",
    [
        "0",
        "0.00",
        "-10.00",
        "0.001",
        "10.005",
        "1E-3",
        "10000000000000000",
        "1E+16",
        "NaN",
        "sNaN",
        "Infinity",
        "-Infinity",
    ],
)
def test_rejects_amount_not_representable_as_positive_money(
    harness: Harness, amount: str
) -> None:
    with pytest.raises(InvalidAmountError):
        harness.execute(ars(amount))

    harness.assert_no_writes()
    assert harness.accounts.locked_reads == []


def test_accepts_largest_representable_amount() -> None:
    largest = ars("9999999999999999.99")
    harness = Harness(make_account(balance=largest), make_beneficiary())

    harness.execute(largest)

    assert harness.accounts.stored(harness.account.id).balance == ars("0.00")


def test_rejects_unknown_source_account(harness: Harness) -> None:
    with pytest.raises(AccountNotFoundError):
        harness.execute(ars("100.00"), source_account_id=uuid4())

    harness.assert_no_writes()
    assert harness.beneficiaries.reads == 0


def test_rejects_source_account_owned_by_another_customer() -> None:
    other_account = make_account(customer_id=OTHER_CUSTOMER_ID)
    harness = Harness(other_account, make_beneficiary())

    with pytest.raises(AccountNotFoundError):
        harness.execute(ars("100.00"))

    harness.assert_no_writes()


def test_rejects_unknown_beneficiary(harness: Harness) -> None:
    with pytest.raises(BeneficiaryNotFoundError):
        harness.execute(ars("100.00"), beneficiary_id=uuid4())

    harness.assert_no_writes()


def test_rejects_beneficiary_owned_by_another_customer() -> None:
    harness = Harness(make_account(), make_beneficiary(customer_id=OTHER_CUSTOMER_ID))

    with pytest.raises(BeneficiaryNotFoundError):
        harness.execute(ars("100.00"))

    harness.assert_no_writes()


def test_rejects_inactive_source_account() -> None:
    harness = Harness(make_account(status=AccountStatus.INACTIVE), make_beneficiary())

    with pytest.raises(InvalidAccountStateError):
        harness.execute(ars("100.00"))

    harness.assert_no_writes()


def test_rejects_currency_mismatch(harness: Harness) -> None:
    with pytest.raises(InvalidAmountError):
        harness.execute(Money(Decimal("100.00"), Currency.USD))

    harness.assert_no_writes()


def test_rejects_insufficient_funds(harness: Harness) -> None:
    with pytest.raises(InsufficientFundsError):
        harness.execute(ars("150000.51"))

    harness.assert_no_writes()


def test_rejects_naive_clock_without_writes() -> None:
    harness = Harness(
        make_account(), make_beneficiary(), clock_value=datetime(2026, 10, 9, 16, 30)
    )

    with pytest.raises(ValueError):
        harness.execute(ars("100.00"))

    harness.assert_no_writes()


@pytest.mark.parametrize(
    ("error", "category", "code"),
    [
        (AccountNotFoundError, NotFoundError, "ACCOUNT_NOT_FOUND"),
        (InvalidAccountStateError, ConflictError, "INVALID_ACCOUNT_STATE"),
        (InvalidAmountError, BusinessRuleViolationError, "INVALID_AMOUNT"),
        (InsufficientFundsError, BusinessRuleViolationError, "INSUFFICIENT_FUNDS"),
    ],
)
def test_transfer_errors_use_documented_codes(
    error: type[ApplicationError], category: type[ApplicationError], code: str
) -> None:
    instance = error()

    assert isinstance(instance, category)
    assert instance.code == code
