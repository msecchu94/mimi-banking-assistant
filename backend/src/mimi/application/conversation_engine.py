from collections.abc import Callable
from dataclasses import dataclass
from datetime import datetime
from uuid import UUID, uuid4

from mimi.application.errors import ConversationClosedError, ConversationNotFoundError
from mimi.application.repositories import ConversationRecord, TransactionScope
from mimi.domain.entities import Conversation, Message
from mimi.domain.enums import ConversationFlowState, ConversationStatus, MessageRole


@dataclass(frozen=True)
class Turn:
    """Outcome of handling one user message."""

    conversation_id: UUID
    flow_state: ConversationFlowState
    message: Message


class ConversationEngine:
    """Orchestrate conversations between a customer and Mimi.

    Each public method runs in its own transaction: its writes commit together
    or not at all. The conversation row stays locked while a message is
    handled, so turns on the same conversation do not interleave.
    """

    def __init__(
        self, transaction_scope: TransactionScope, clock: Callable[[], datetime]
    ) -> None:
        self._transaction_scope = transaction_scope
        self._clock = clock

    def start(self, customer_id: UUID) -> ConversationRecord:
        """Create an ACTIVE conversation in the READY flow state."""
        now = self._now()
        record = ConversationRecord(
            conversation=Conversation(
                id=uuid4(),
                customer_id=customer_id,
                status=ConversationStatus.ACTIVE,
                created_at=now,
                updated_at=now,
            ),
            flow_state=ConversationFlowState.READY,
        )
        with self._transaction_scope.begin() as repositories:
            repositories.conversations.add(record)
        return record

    def handle_message(
        self, customer_id: UUID, conversation_id: UUID, content: str
    ) -> Turn:
        """Persist a user message in an owned ACTIVE conversation.

        Raises ``ConversationNotFoundError`` when the conversation does not
        exist or is not owned by the customer, and ``ConversationClosedError``
        when it is CLOSED.
        """
        if not content.strip():
            raise ValueError("message content must not be blank")

        with self._transaction_scope.begin() as repositories:
            record = repositories.conversations.get_for_update(
                customer_id, conversation_id
            )
            if record is None:
                raise ConversationNotFoundError()
            if record.conversation.status is ConversationStatus.CLOSED:
                raise ConversationClosedError()

            now = self._now()
            message = Message(
                id=uuid4(),
                conversation_id=conversation_id,
                role=MessageRole.USER,
                content=content,
                created_at=now,
            )
            repositories.messages.add(message)
            repositories.conversations.touch(conversation_id, now)
        return Turn(
            conversation_id=conversation_id,
            flow_state=record.flow_state,
            message=message,
        )

    def _now(self) -> datetime:
        now = self._clock()
        if now.tzinfo is None or now.utcoffset() is None:
            raise ValueError("clock must return a timezone-aware datetime")
        return now
