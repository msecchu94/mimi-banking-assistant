"""The state-changing operation pending in one active Conversation.

Operation data holds only resolved, valid values, so a required field is
missing exactly when it is unset. A transfer's unresolved amount is a
candidate, not a resolved value: the amount stays missing. Completeness does
not imply pre-validation: only the caller that pre-validated a complete
operation may place it in ``WAITING_CONFIRMATION``.
"""

from dataclasses import dataclass
from decimal import Decimal
from enum import StrEnum
from uuid import UUID

from mimi.application.amounts import is_valid_transfer_amount
from mimi.domain.entities import Money
from mimi.domain.enums import ConversationFlowState, PendingOperationType


class PendingField(StrEnum):
    """Required operation data, as named in CONVERSATION.md."""

    SOURCE_ACCOUNT_ID = "source_account_id"
    BENEFICIARY_ID = "beneficiary_id"
    AMOUNT = "amount"
    CARD_ID = "card_id"


@dataclass(frozen=True)
class TransferOperationData:
    """``unresolved_amount`` is a valid amount the user stated before its
    currency could be determined. It is a candidate, not resolved data: the
    amount stays missing until it becomes ``amount``."""

    source_account_id: UUID | None = None
    beneficiary_id: UUID | None = None
    amount: Money | None = None
    unresolved_amount: Decimal | None = None

    def __post_init__(self) -> None:
        if self.amount is not None and not is_valid_transfer_amount(self.amount.amount):
            raise ValueError("a resolved transfer amount must be valid")
        if self.unresolved_amount is not None:
            if self.amount is not None:
                raise ValueError("an amount is either resolved or unresolved")
            if not is_valid_transfer_amount(self.unresolved_amount):
                raise ValueError("an unresolved transfer amount must be valid")

    @property
    def missing_fields(self) -> tuple[PendingField, ...]:
        values = (
            (PendingField.SOURCE_ACCOUNT_ID, self.source_account_id),
            (PendingField.BENEFICIARY_ID, self.beneficiary_id),
            (PendingField.AMOUNT, self.amount),
        )
        return tuple(field for field, value in values if value is None)


@dataclass(frozen=True)
class FreezeCardOperationData:
    card_id: UUID | None = None

    @property
    def missing_fields(self) -> tuple[PendingField, ...]:
        return (PendingField.CARD_ID,) if self.card_id is None else ()


@dataclass(frozen=True)
class UnfreezeCardOperationData:
    card_id: UUID | None = None

    @property
    def missing_fields(self) -> tuple[PendingField, ...]:
        return (PendingField.CARD_ID,) if self.card_id is None else ()


PendingOperationData = (
    TransferOperationData | FreezeCardOperationData | UnfreezeCardOperationData
)

_DATA_TYPE: dict[PendingOperationType, type[PendingOperationData]] = {
    PendingOperationType.TRANSFER: TransferOperationData,
    PendingOperationType.FREEZE_CARD: FreezeCardOperationData,
    PendingOperationType.UNFREEZE_CARD: UnfreezeCardOperationData,
}


@dataclass(frozen=True)
class PendingOperation:
    """A pending operation; ``operation_id`` identifies the confirmation
    request of an operation waiting for confirmation, and is ``None`` otherwise.

    Every pre-validated confirmation request gets a fresh ``operation_id``, so
    a ``CONFIRM`` issued for an earlier request never matches a later one.
    """

    type: PendingOperationType
    data: PendingOperationData
    operation_id: UUID | None = None

    def __post_init__(self) -> None:
        if type(self.data) is not _DATA_TYPE[self.type]:
            raise ValueError(f"{self.type} requires {_DATA_TYPE[self.type].__name__}")

    @property
    def missing_fields(self) -> tuple[PendingField, ...]:
        """Required fields still unresolved, in a fixed order."""
        return self.data.missing_fields


def check_pending_state(
    flow_state: ConversationFlowState, pending_operation: PendingOperation | None
) -> None:
    """Raise ``ValueError`` unless the flow state agrees with the operation.

    ``WAITING_CONFIRMATION`` requires a complete operation with an
    ``operation_id`` but cannot verify that it was pre-validated; that remains
    the caller's responsibility. A collected operation has no ``operation_id``.
    """
    match flow_state:
        case ConversationFlowState.READY:
            valid = pending_operation is None
        case ConversationFlowState.COLLECTING_DATA:
            valid = (
                pending_operation is not None
                and bool(pending_operation.missing_fields)
                and pending_operation.operation_id is None
            )
        case ConversationFlowState.WAITING_CONFIRMATION:
            valid = (
                pending_operation is not None
                and not pending_operation.missing_fields
                and pending_operation.operation_id is not None
            )
    if not valid:
        raise ValueError(f"{flow_state} does not match the pending operation")
