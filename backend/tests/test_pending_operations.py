from datetime import UTC, datetime
from decimal import Decimal
from uuid import uuid4

import pytest

from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingField,
    PendingOperation,
    PendingOperationData,
    TransferOperationData,
    UnfreezeCardOperationData,
    check_pending_state,
)
from mimi.application.repositories import ConversationRecord
from mimi.domain.entities import Conversation, Money
from mimi.domain.enums import (
    ConversationFlowState,
    ConversationStatus,
    Currency,
    PendingOperationType,
)

READY = ConversationFlowState.READY
COLLECTING_DATA = ConversationFlowState.COLLECTING_DATA
WAITING_CONFIRMATION = ConversationFlowState.WAITING_CONFIRMATION
TRANSFER = PendingOperationType.TRANSFER
FREEZE_CARD = PendingOperationType.FREEZE_CARD
UNFREEZE_CARD = PendingOperationType.UNFREEZE_CARD

AMOUNT = Money(Decimal("25000.00"), Currency.ARS)
COMPLETE_TRANSFER = PendingOperation(
    TRANSFER, TransferOperationData(uuid4(), uuid4(), AMOUNT)
)
PARTIAL_TRANSFER = PendingOperation(
    TRANSFER, TransferOperationData(beneficiary_id=uuid4())
)


@pytest.mark.parametrize(
    ("operation", "missing"),
    [
        (
            PendingOperation(TRANSFER, TransferOperationData()),
            (
                PendingField.SOURCE_ACCOUNT_ID,
                PendingField.BENEFICIARY_ID,
                PendingField.AMOUNT,
            ),
        ),
        (PARTIAL_TRANSFER, (PendingField.SOURCE_ACCOUNT_ID, PendingField.AMOUNT)),
        (
            PendingOperation(TRANSFER, TransferOperationData(uuid4(), None, AMOUNT)),
            (PendingField.BENEFICIARY_ID,),
        ),
        (COMPLETE_TRANSFER, ()),
        (
            PendingOperation(
                TRANSFER,
                TransferOperationData(
                    uuid4(), uuid4(), unresolved_amount=Decimal("25000")
                ),
            ),
            (PendingField.AMOUNT,),
        ),
        (
            PendingOperation(
                TRANSFER,
                TransferOperationData(unresolved_amount=Decimal("25000")),
            ),
            (
                PendingField.SOURCE_ACCOUNT_ID,
                PendingField.BENEFICIARY_ID,
                PendingField.AMOUNT,
            ),
        ),
        (
            PendingOperation(FREEZE_CARD, FreezeCardOperationData()),
            (PendingField.CARD_ID,),
        ),
        (PendingOperation(FREEZE_CARD, FreezeCardOperationData(uuid4())), ()),
        (
            PendingOperation(UNFREEZE_CARD, UnfreezeCardOperationData()),
            (PendingField.CARD_ID,),
        ),
        (PendingOperation(UNFREEZE_CARD, UnfreezeCardOperationData(uuid4())), ()),
    ],
)
def test_missing_fields_are_the_unresolved_required_fields(
    operation: PendingOperation, missing: tuple[PendingField, ...]
) -> None:
    assert operation.missing_fields == missing


@pytest.mark.parametrize(
    ("operation_type", "data"),
    [
        (TRANSFER, FreezeCardOperationData()),
        (FREEZE_CARD, UnfreezeCardOperationData()),
        (UNFREEZE_CARD, FreezeCardOperationData()),
        (FREEZE_CARD, TransferOperationData()),
    ],
)
def test_operation_data_must_match_its_type(
    operation_type: PendingOperationType, data: PendingOperationData
) -> None:
    with pytest.raises(ValueError, match="requires"):
        PendingOperation(operation_type, data)


@pytest.mark.parametrize(
    "amount",
    ["0", "0.00", "-50", "0.001", "25000.005", "NaN", "Infinity", "1E+16"],
)
def test_resolved_transfer_amount_must_be_valid(amount: str) -> None:
    with pytest.raises(ValueError, match="amount"):
        TransferOperationData(amount=Money(Decimal(amount), Currency.ARS))


@pytest.mark.parametrize(
    "amount",
    ["0", "0.00", "-50", "0.001", "25000.005", "NaN", "Infinity", "1E+16"],
)
def test_unresolved_transfer_amount_must_be_valid(amount: str) -> None:
    with pytest.raises(ValueError, match="amount"):
        TransferOperationData(unresolved_amount=Decimal(amount))


def test_amount_is_either_resolved_or_unresolved() -> None:
    with pytest.raises(ValueError, match="either"):
        TransferOperationData(amount=AMOUNT, unresolved_amount=Decimal("25000"))


@pytest.mark.parametrize("amount", ["0.01", "25000", "25000.50", "1.500"])
def test_valid_transfer_amount_is_accepted(amount: str) -> None:
    data = TransferOperationData(amount=Money(Decimal(amount), Currency.USD))

    assert PendingField.AMOUNT not in data.missing_fields


@pytest.mark.parametrize(
    ("flow_state", "operation"),
    [
        (READY, None),
        (COLLECTING_DATA, PARTIAL_TRANSFER),
        (WAITING_CONFIRMATION, COMPLETE_TRANSFER),
    ],
)
def test_consistent_pending_states_are_accepted(
    flow_state: ConversationFlowState, operation: PendingOperation | None
) -> None:
    check_pending_state(flow_state, operation)


@pytest.mark.parametrize(
    ("flow_state", "operation"),
    [
        (READY, PARTIAL_TRANSFER),
        (READY, COMPLETE_TRANSFER),
        (COLLECTING_DATA, None),
        # A complete operation is never collecting data; whether it may wait
        # for confirmation depends on the caller's pre-validation.
        (COLLECTING_DATA, COMPLETE_TRANSFER),
        (WAITING_CONFIRMATION, None),
        (WAITING_CONFIRMATION, PARTIAL_TRANSFER),
        # An unresolved amount is a candidate, never confirmable data.
        (
            WAITING_CONFIRMATION,
            PendingOperation(
                TRANSFER,
                TransferOperationData(
                    uuid4(), uuid4(), unresolved_amount=Decimal("25000")
                ),
            ),
        ),
    ],
)
def test_inconsistent_pending_states_are_rejected(
    flow_state: ConversationFlowState, operation: PendingOperation | None
) -> None:
    with pytest.raises(ValueError, match="does not match"):
        check_pending_state(flow_state, operation)


def make_record(
    status: ConversationStatus,
    flow_state: ConversationFlowState,
    operation: PendingOperation | None,
) -> ConversationRecord:
    now = datetime(2026, 10, 9, 16, 31, 4, tzinfo=UTC)
    return ConversationRecord(
        conversation=Conversation(uuid4(), uuid4(), status, now, now),
        flow_state=flow_state,
        pending_operation=operation,
    )


def test_record_enforces_flow_state_invariants() -> None:
    record = make_record(ConversationStatus.ACTIVE, COLLECTING_DATA, PARTIAL_TRANSFER)
    assert record.pending_operation == PARTIAL_TRANSFER

    with pytest.raises(ValueError, match="does not match"):
        make_record(ConversationStatus.ACTIVE, READY, PARTIAL_TRANSFER)


def test_closed_record_has_no_pending_operation() -> None:
    assert make_record(ConversationStatus.CLOSED, READY, None).pending_operation is None

    with pytest.raises(ValueError, match="closed"):
        make_record(ConversationStatus.CLOSED, WAITING_CONFIRMATION, COMPLETE_TRANSFER)
