"""Persistence ports required by V1 Use Cases.

Single reads return ``None`` when the record does not exist or is not owned by
the given customer. List reads return an empty list when nothing matches.

Updates expect the caller to have read the record earlier in the same
transaction.
"""

from contextlib import AbstractContextManager
from dataclasses import dataclass
from datetime import datetime
from typing import Protocol
from uuid import UUID

from mimi.application.conversation_context import EMPTY_CONTEXT, ConversationContext
from mimi.application.pending_operations import PendingOperation, check_pending_state
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
    TransactionCategory,
    TransactionType,
)


class AccountRepository(Protocol):
    def list_by_customer(self, customer_id: UUID) -> list[Account]: ...

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        """Return the owned account, locked until the current transaction ends."""
        ...

    def update_balance(self, account_id: UUID, balance: Money) -> None: ...


class CardRepository(Protocol):
    def list_by_customer(self, customer_id: UUID) -> list[Card]: ...

    def get(self, customer_id: UUID, card_id: UUID) -> Card | None: ...

    def update_status(self, card_id: UUID, status: CardStatus) -> None: ...


class BeneficiaryRepository(Protocol):
    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]: ...

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None: ...


@dataclass(frozen=True)
class TransactionQuery:
    """Filters for a customer's transactions; unset fields do not filter.

    The period is half-open: ``occurred_from`` inclusive, ``occurred_to``
    exclusive. Both must be timezone-aware.
    """

    occurred_from: datetime | None = None
    occurred_to: datetime | None = None
    category: TransactionCategory | None = None
    type: TransactionType | None = None
    limit: int | None = None


class TransactionRepository(Protocol):
    def list_by_customer(
        self, customer_id: UUID, query: TransactionQuery
    ) -> list[Transaction]:
        """Return matching transactions, newest first."""
        ...


class TransferRepository(Protocol):
    def add(self, transfer: Transfer, transaction: Transaction | None) -> None:
        """Persist a transfer together with its resulting transaction, if any."""
        ...


@dataclass(frozen=True)
class ConversationRecord:
    """A Conversation together with its persisted conversational state."""

    conversation: Conversation
    flow_state: ConversationFlowState
    context: ConversationContext = EMPTY_CONTEXT
    pending_operation: PendingOperation | None = None

    def __post_init__(self) -> None:
        check_pending_state(self.flow_state, self.pending_operation)
        if (
            self.conversation.status is ConversationStatus.CLOSED
            and self.pending_operation is not None
        ):
            raise ValueError("a closed conversation has no pending operation")


class ConversationRepository(Protocol):
    def add(self, record: ConversationRecord) -> None:
        """Persist a new conversation with no pending operation."""
        ...

    def get_for_update(
        self, customer_id: UUID, conversation_id: UUID
    ) -> ConversationRecord | None:
        """Return the owned conversation, locked until the current transaction ends.

        Raises ``ConversationStateCorruptedError`` when the persisted flow state
        or pending operation is malformed or inconsistent.
        """
        ...

    def save_pending_operation(
        self,
        conversation_id: UUID,
        flow_state: ConversationFlowState,
        pending_operation: PendingOperation | None,
    ) -> None:
        """Replace the flow state and pending operation together.

        ``READY`` with ``None`` clears the operation. ``WAITING_CONFIRMATION``
        may be saved only after the caller pre-validated the complete
        operation, with the ``operation_id`` of its confirmation request.
        Raises ``ValueError`` when the state is inconsistent.
        """
        ...

    def mark_closed(self, conversation_id: UUID) -> None:
        """Set the conversation's status to CLOSED; its pending operation must
        already be cleared."""
        ...

    def touch(self, conversation_id: UUID, updated_at: datetime) -> None: ...

    def save_context(
        self, conversation_id: UUID, context: ConversationContext
    ) -> None: ...


class MessageRepository(Protocol):
    def add(self, message: Message) -> None: ...

    def list_by_conversation(self, conversation_id: UUID) -> list[Message]:
        """Return the conversation's messages, oldest first."""
        ...


class Repositories(Protocol):
    """Repositories sharing one transaction."""

    @property
    def accounts(self) -> AccountRepository: ...

    @property
    def cards(self) -> CardRepository: ...

    @property
    def beneficiaries(self) -> BeneficiaryRepository: ...

    @property
    def transactions(self) -> TransactionRepository: ...

    @property
    def transfers(self) -> TransferRepository: ...

    @property
    def conversations(self) -> ConversationRepository: ...

    @property
    def messages(self) -> MessageRepository: ...


class TransactionScope(Protocol):
    def begin(self) -> AbstractContextManager[Repositories]:
        """Commit on normal exit and roll back on exception."""
        ...
