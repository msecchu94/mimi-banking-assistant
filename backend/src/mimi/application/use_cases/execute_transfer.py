from collections.abc import Callable
from datetime import datetime
from uuid import UUID, uuid4

from mimi.application.amounts import is_valid_transfer_amount
from mimi.application.errors import (
    AccountNotFoundError,
    BeneficiaryNotFoundError,
    InsufficientFundsError,
    InvalidAccountStateError,
    InvalidAmountError,
)
from mimi.application.repositories import (
    AccountRepository,
    BeneficiaryRepository,
    TransferRepository,
)
from mimi.domain.entities import Account, Beneficiary, Money, Transaction, Transfer
from mimi.domain.enums import (
    AccountStatus,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)


def validate_transfer(
    account: Account | None,
    find_beneficiary: Callable[[], Beneficiary | None],
    amount: Money,
) -> tuple[Account, Beneficiary]:
    """Check a transfer of ``amount`` against the current state of its owned
    source account and saved beneficiary, ``None`` when not found.

    The beneficiary is looked up only once the source account is found.
    Raises the semantic error of the first rule that fails; returns the
    account and beneficiary otherwise.
    """
    if not is_valid_transfer_amount(amount.amount):
        raise InvalidAmountError()
    if account is None:
        raise AccountNotFoundError()
    beneficiary = find_beneficiary()
    if beneficiary is None:
        raise BeneficiaryNotFoundError()
    if account.status is not AccountStatus.ACTIVE:
        raise InvalidAccountStateError()
    if amount.currency is not account.balance.currency:
        raise InvalidAmountError()
    if account.balance.amount < amount.amount:
        raise InsufficientFundsError()
    return account, beneficiary


class ExecuteTransfer:
    """Execute a simulated transfer from an owned account to a saved beneficiary.

    Every precondition is validated on each execution, so calling it after
    confirmation revalidates the operation against current state. Validation
    failures raise before any write and create no Transfer.

    The caller owns the transaction: the balance update, the Transfer and its
    Transaction commit or roll back together with it. The source account is
    locked until that transaction ends.
    """

    def __init__(
        self,
        accounts: AccountRepository,
        beneficiaries: BeneficiaryRepository,
        transfers: TransferRepository,
        clock: Callable[[], datetime],
    ) -> None:
        self._accounts = accounts
        self._beneficiaries = beneficiaries
        self._transfers = transfers
        self._clock = clock

    def execute(
        self,
        *,
        customer_id: UUID,
        source_account_id: UUID,
        beneficiary_id: UUID,
        amount: Money,
    ) -> Transfer:
        if not is_valid_transfer_amount(amount.amount):
            raise InvalidAmountError()

        account, beneficiary = validate_transfer(
            self._accounts.get_for_update(customer_id, source_account_id),
            lambda: self._beneficiaries.get(customer_id, beneficiary_id),
            amount,
        )

        now = self._clock()
        if now.tzinfo is None or now.utcoffset() is None:
            raise ValueError("clock must return a timezone-aware datetime")

        transfer = Transfer(
            id=uuid4(),
            source_account_id=account.id,
            beneficiary_id=beneficiary.id,
            amount=amount,
            status=TransferStatus.COMPLETED,
            created_at=now,
            executed_at=now,
        )
        transaction = Transaction(
            id=uuid4(),
            account_id=account.id,
            amount=amount,
            type=TransactionType.DEBIT,
            category=TransactionCategory.TRANSFER,
            description=f"Transfer to {beneficiary.name}",
            occurred_at=now,
            transfer_id=transfer.id,
        )
        self._accounts.update_balance(
            account.id,
            Money(account.balance.amount - amount.amount, amount.currency),
        )
        self._transfers.add(transfer, transaction)
        return transfer
