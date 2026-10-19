"""PostgreSQL adapters for the Application repository ports.

Adapters use the Session they are given and never commit, roll back or close
it; the transaction scope owns those decisions. Relationships are never
traversed: reads are explicit selects mapped to Domain entities, so no ORM
object leaves this module.
"""

from datetime import datetime
from typing import Any, cast
from uuid import UUID

from sqlalchemy import CursorResult, Update, select, update
from sqlalchemy.orm import Session

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
from mimi.domain.enums import CardStatus
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


def _to_conversation_record(model: ConversationModel) -> ConversationRecord:
    return ConversationRecord(
        conversation=Conversation(
            id=model.id,
            customer_id=model.customer_id,
            status=model.status,
            created_at=model.created_at,
            updated_at=model.updated_at,
        ),
        flow_state=model.flow_state,
    )


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
        conversation = record.conversation
        self._session.add(
            ConversationModel(
                id=conversation.id,
                customer_id=conversation.customer_id,
                status=conversation.status,
                created_at=conversation.created_at,
                updated_at=conversation.updated_at,
                flow_state=record.flow_state,
                context={},
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

    def touch(self, conversation_id: UUID, updated_at: datetime) -> None:
        _update_one(
            self._session,
            update(ConversationModel)
            .where(ConversationModel.id == conversation_id)
            .values(updated_at=updated_at),
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
