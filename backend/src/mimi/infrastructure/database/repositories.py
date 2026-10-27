"""PostgreSQL adapters for the Application repository ports.

Adapters use the Session they are given and never commit, roll back or close
it; the transaction scope owns those decisions. Relationships are never
traversed: reads are explicit selects mapped to Domain entities, so no ORM
object leaves this module.
"""

from datetime import datetime
from typing import Any, Literal, cast
from uuid import UUID

from pydantic import AwareDatetime, BaseModel, ConfigDict, ValidationError
from sqlalchemy import CursorResult, Update, select, update
from sqlalchemy.orm import Session

from mimi.application.conversation_context import (
    EMPTY_CONTEXT,
    ConversationContext,
    TemporalContext,
)
from mimi.application.errors import ConversationStateCorruptedError
from mimi.application.interpretation import Intent, PeriodReference
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingField,
    PendingOperation,
    PendingOperationData,
    TransferOperationData,
    UnfreezeCardOperationData,
    check_pending_state,
)
from mimi.application.repositories import ConversationRecord, TransactionQuery
from mimi.domain.entities import (
    Account,
    Beneficiary,
    Card,
    Conversation,
    Message,
    Money,
    Transaction,
    Transfer,
)
from mimi.domain.enums import (
    CardStatus,
    ConversationFlowState,
    ConversationStatus,
    PendingOperationType,
    TransactionCategory,
    TransactionType,
)
from mimi.infrastructure.database.models import (
    AccountModel,
    BeneficiaryModel,
    CardModel,
    ConversationModel,
    MessageModel,
    TransactionModel,
    TransferModel,
)


def _update_one(session: Session, statement: Update) -> None:
    result = cast(CursorResult[Any], session.execute(statement))
    if result.rowcount != 1:
        raise RuntimeError(f"Expected to update one row, updated {result.rowcount}")


def _to_account(model: AccountModel) -> Account:
    return Account(
        id=model.id,
        customer_id=model.customer_id,
        name=model.name,
        balance=Money(model.balance, model.currency),
        status=model.status,
    )


def _to_card(model: CardModel) -> Card:
    return Card(
        id=model.id,
        account_id=model.account_id,
        type=model.type,
        brand=model.brand,
        last_four=model.last_four,
        status=model.status,
    )


def _to_beneficiary(model: BeneficiaryModel) -> Beneficiary:
    return Beneficiary(
        id=model.id,
        customer_id=model.customer_id,
        name=model.name,
        account_reference=model.account_reference,
        bank_name=model.bank_name,
    )


def _to_transaction(model: TransactionModel) -> Transaction:
    return Transaction(
        id=model.id,
        account_id=model.account_id,
        amount=Money(model.amount, model.currency),
        type=model.type,
        category=model.category,
        description=model.description,
        occurred_at=model.occurred_at,
        transfer_id=model.transfer_id,
    )


class _StoredTemporalContext(BaseModel):
    model_config = ConfigDict(extra="forbid")

    period: PeriodReference
    comparison_period: PeriodReference | None
    anchored_at: AwareDatetime


class _StoredContext(BaseModel):
    """JSON representation of a non-empty ``ConversationContext``."""

    model_config = ConfigDict(extra="forbid")

    version: Literal[1] = 1
    last_intent: Intent
    category: TransactionCategory | None
    transaction_type: TransactionType | None
    temporal: _StoredTemporalContext | None


def _context_to_json(context: ConversationContext) -> dict[str, Any]:
    if context.last_intent is None:
        return {}
    temporal = context.temporal
    return _StoredContext(
        last_intent=context.last_intent,
        category=context.category,
        transaction_type=context.transaction_type,
        temporal=(
            None
            if temporal is None
            else _StoredTemporalContext(
                period=temporal.period,
                comparison_period=temporal.comparison_period,
                anchored_at=temporal.anchored_at,
            )
        ),
    ).model_dump(mode="json")


def _context_from_json(data: dict[str, Any]) -> ConversationContext:
    """Load a stored context; a malformed one loads as empty.

    Context never holds financial truth, and a follow-up without context
    executes no query, so an unreadable context fails safe.
    """
    if not data:
        return EMPTY_CONTEXT
    try:
        stored = _StoredContext.model_validate(data)
    except ValidationError:
        return EMPTY_CONTEXT
    temporal = stored.temporal
    return ConversationContext(
        last_intent=stored.last_intent,
        category=stored.category,
        transaction_type=stored.transaction_type,
        temporal=(
            None
            if temporal is None
            else TemporalContext(
                temporal.period, temporal.comparison_period, temporal.anchored_at
            )
        ),
    )


def _pending_operation_columns(
    pending_operation: PendingOperation | None,
) -> dict[str, Any]:
    """Values for every pending column; columns the operation does not use are
    cleared."""
    columns: dict[str, Any] = {
        "pending_operation_type": None,
        "pending_operation_id": None,
        "pending_source_account_id": None,
        "pending_beneficiary_id": None,
        "pending_amount": None,
        "pending_currency": None,
        "pending_card_id": None,
        "pending_missing_fields": None,
    }
    if pending_operation is None:
        return columns
    columns["pending_operation_type"] = pending_operation.type
    columns["pending_operation_id"] = pending_operation.operation_id
    columns["pending_missing_fields"] = [
        field.value for field in pending_operation.missing_fields
    ]
    data = pending_operation.data
    match data:
        case TransferOperationData():
            columns["pending_source_account_id"] = data.source_account_id
            columns["pending_beneficiary_id"] = data.beneficiary_id
            if data.amount is not None:
                columns["pending_amount"] = data.amount.amount
                columns["pending_currency"] = data.amount.currency
            elif data.unresolved_amount is not None:
                # An amount without currency is the unresolved candidate.
                columns["pending_amount"] = data.unresolved_amount
        case FreezeCardOperationData() | UnfreezeCardOperationData():
            columns["pending_card_id"] = data.card_id
    return columns


def _pending_operation_from_model(model: ConversationModel) -> PendingOperation | None:
    """Load the pending operation; raise ``ValueError`` when its stored data or
    missing fields are inconsistent."""
    operation_type = model.pending_operation_type
    if operation_type is None:
        return None
    data: PendingOperationData
    match operation_type:
        case PendingOperationType.TRANSFER:
            if model.pending_amount is None and model.pending_currency is not None:
                raise ValueError("a stored currency requires an amount")
            resolved = model.pending_currency is not None
            data = TransferOperationData(
                source_account_id=model.pending_source_account_id,
                beneficiary_id=model.pending_beneficiary_id,
                amount=(
                    Money(model.pending_amount, model.pending_currency)
                    if model.pending_amount is not None
                    and model.pending_currency is not None
                    else None
                ),
                unresolved_amount=None if resolved else model.pending_amount,
            )
        case PendingOperationType.FREEZE_CARD:
            data = FreezeCardOperationData(card_id=model.pending_card_id)
        case PendingOperationType.UNFREEZE_CARD:
            data = UnfreezeCardOperationData(card_id=model.pending_card_id)
    pending_operation = PendingOperation(
        operation_type, data, model.pending_operation_id
    )
    stored = [PendingField(field) for field in model.pending_missing_fields or ()]
    if len(stored) != len(set(stored)) or set(stored) != set(
        pending_operation.missing_fields
    ):
        raise ValueError("stored missing fields do not match the operation data")
    return pending_operation


def _to_conversation_record(model: ConversationModel) -> ConversationRecord:
    """Map a stored conversation; raise ``ConversationStateCorruptedError`` when
    its authoritative flow state or pending operation is inconsistent.

    Unlike context, the pending operation is never dropped: discarding it would
    silently change what the user is asked to confirm.
    """
    try:
        return ConversationRecord(
            conversation=Conversation(
                id=model.id,
                customer_id=model.customer_id,
                status=model.status,
                created_at=model.created_at,
                updated_at=model.updated_at,
            ),
            flow_state=model.flow_state,
            context=_context_from_json(model.context),
            pending_operation=_pending_operation_from_model(model),
        )
    except ValueError as exc:
        raise ConversationStateCorruptedError(
            f"conversation {model.id} has inconsistent pending state"
        ) from exc


def _to_message(model: MessageModel) -> Message:
    return Message(
        id=model.id,
        conversation_id=model.conversation_id,
        role=model.role,
        content=model.content,
        created_at=model.created_at,
    )


class PostgresAccountRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def list_by_customer(self, customer_id: UUID) -> list[Account]:
        models = self._session.scalars(
            select(AccountModel)
            .where(AccountModel.customer_id == customer_id)
            .order_by(AccountModel.name, AccountModel.id)
        )
        return [_to_account(model) for model in models]

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        model = self._session.scalars(
            select(AccountModel)
            .where(
                AccountModel.id == account_id,
                AccountModel.customer_id == customer_id,
            )
            .with_for_update()
        ).one_or_none()
        return _to_account(model) if model else None

    def update_balance(self, account_id: UUID, balance: Money) -> None:
        # Matching on currency keeps the stored balance and currency consistent.
        _update_one(
            self._session,
            update(AccountModel)
            .where(
                AccountModel.id == account_id,
                AccountModel.currency == balance.currency,
            )
            .values(balance=balance.amount),
        )


class PostgresCardRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def list_by_customer(self, customer_id: UUID) -> list[Card]:
        models = self._session.scalars(
            select(CardModel)
            .join(AccountModel, CardModel.account_id == AccountModel.id)
            .where(AccountModel.customer_id == customer_id)
            .order_by(CardModel.brand, CardModel.last_four, CardModel.id)
        )
        return [_to_card(model) for model in models]

    def get(self, customer_id: UUID, card_id: UUID) -> Card | None:
        model = self._session.scalars(
            select(CardModel)
            .join(AccountModel, CardModel.account_id == AccountModel.id)
            .where(CardModel.id == card_id, AccountModel.customer_id == customer_id)
        ).one_or_none()
        return _to_card(model) if model else None

    def update_status(self, card_id: UUID, status: CardStatus) -> None:
        _update_one(
            self._session,
            update(CardModel).where(CardModel.id == card_id).values(status=status),
        )


class PostgresBeneficiaryRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]:
        models = self._session.scalars(
            select(BeneficiaryModel)
            .where(BeneficiaryModel.customer_id == customer_id)
            .order_by(BeneficiaryModel.name, BeneficiaryModel.id)
        )
        return [_to_beneficiary(model) for model in models]

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None:
        model = self._session.scalars(
            select(BeneficiaryModel).where(
                BeneficiaryModel.id == beneficiary_id,
                BeneficiaryModel.customer_id == customer_id,
            )
        ).one_or_none()
        return _to_beneficiary(model) if model else None


class PostgresTransactionRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        statement = (
            select(TransactionModel)
            .join(AccountModel, TransactionModel.account_id == AccountModel.id)
            .where(AccountModel.customer_id == customer_id)
            .order_by(TransactionModel.occurred_at.desc(), TransactionModel.id.desc())
        )
        if query.occurred_from is not None:
            statement = statement.where(
                TransactionModel.occurred_at >= query.occurred_from
            )
        if query.occurred_to is not None:
            statement = statement.where(
                TransactionModel.occurred_at < query.occurred_to
            )
        if query.category is not None:
            statement = statement.where(TransactionModel.category == query.category)
        if query.type is not None:
            statement = statement.where(TransactionModel.type == query.type)
        if query.limit is not None:
            statement = statement.limit(query.limit)
        return [_to_transaction(model) for model in self._session.scalars(statement)]


class PostgresTransferRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, transfer: Transfer, transaction: Transaction | None) -> None:
        self._session.add(
            TransferModel(
                id=transfer.id,
                source_account_id=transfer.source_account_id,
                beneficiary_id=transfer.beneficiary_id,
                amount=transfer.amount.amount,
                currency=transfer.amount.currency,
                status=transfer.status,
                created_at=transfer.created_at,
                executed_at=transfer.executed_at,
            )
        )
        # The transaction references the transfer, so the transfer goes first.
        self._session.flush()
        if transaction is not None:
            self._session.add(
                TransactionModel(
                    id=transaction.id,
                    account_id=transaction.account_id,
                    amount=transaction.amount.amount,
                    currency=transaction.amount.currency,
                    type=transaction.type,
                    category=transaction.category,
                    description=transaction.description,
                    occurred_at=transaction.occurred_at,
                    transfer_id=transaction.transfer_id,
                )
            )
            self._session.flush()


class PostgresConversationRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, record: ConversationRecord) -> None:
        if record.pending_operation is not None:
            raise ValueError("a new conversation has no pending operation")
        conversation = record.conversation
        self._session.add(
            ConversationModel(
                id=conversation.id,
                customer_id=conversation.customer_id,
                status=conversation.status,
                created_at=conversation.created_at,
                updated_at=conversation.updated_at,
                flow_state=record.flow_state,
                context=_context_to_json(record.context),
            )
        )
        self._session.flush()

    def get_for_update(
        self, customer_id: UUID, conversation_id: UUID
    ) -> ConversationRecord | None:
        model = self._session.scalars(
            select(ConversationModel)
            .where(
                ConversationModel.id == conversation_id,
                ConversationModel.customer_id == customer_id,
            )
            .with_for_update()
        ).one_or_none()
        return _to_conversation_record(model) if model else None

    def save_pending_operation(
        self,
        conversation_id: UUID,
        flow_state: ConversationFlowState,
        pending_operation: PendingOperation | None,
    ) -> None:
        check_pending_state(flow_state, pending_operation)
        _update_one(
            self._session,
            update(ConversationModel)
            .where(ConversationModel.id == conversation_id)
            .values(
                flow_state=flow_state,
                **_pending_operation_columns(pending_operation),
            ),
        )

    def mark_closed(self, conversation_id: UUID) -> None:
        _update_one(
            self._session,
            update(ConversationModel)
            .where(ConversationModel.id == conversation_id)
            .values(status=ConversationStatus.CLOSED),
        )

    def touch(self, conversation_id: UUID, updated_at: datetime) -> None:
        _update_one(
            self._session,
            update(ConversationModel)
            .where(ConversationModel.id == conversation_id)
            .values(updated_at=updated_at),
        )

    def save_context(self, conversation_id: UUID, context: ConversationContext) -> None:
        _update_one(
            self._session,
            update(ConversationModel)
            .where(ConversationModel.id == conversation_id)
            .values(context=_context_to_json(context)),
        )


class PostgresMessageRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, message: Message) -> None:
        self._session.add(
            MessageModel(
                id=message.id,
                conversation_id=message.conversation_id,
                role=message.role,
                content=message.content,
                created_at=message.created_at,
            )
        )
        self._session.flush()

    def list_by_conversation(self, conversation_id: UUID) -> list[Message]:
        models = self._session.scalars(
            select(MessageModel)
            .where(MessageModel.conversation_id == conversation_id)
            .order_by(MessageModel.created_at, MessageModel.id)
        )
        return [_to_message(model) for model in models]
