from collections.abc import Callable
from dataclasses import dataclass
from datetime import datetime
from uuid import UUID, uuid4

from mimi.application.conversation_results import TurnResult
from mimi.application.errors import ConversationClosedError, ConversationNotFoundError
from mimi.application.interpretation import Intent
from mimi.application.read_only_queries import ReadOnlyQueryRouter
from mimi.application.repositories import (
    ConversationRecord,
    Repositories,
    TransactionScope,
)
from mimi.application.use_cases.interpret_message import InterpretMessage
from mimi.domain.entities import Conversation, Message
from mimi.domain.enums import ConversationFlowState, ConversationStatus, MessageRole


@dataclass(frozen=True)
class Turn:
    """Outcome of handling one user message."""

    conversation_id: UUID
    flow_state: ConversationFlowState
    message: Message
    intent: Intent
    result: TurnResult


class ConversationEngine:
    """Orchestrate conversations between a customer and Mimi.

    Each public method commits its writes together or not at all. No
    transaction or lock is held while the message is interpreted: a turn
    checks the conversation first, interprets outside any transaction, then
    locks the conversation, checks it again and records the turn. Turns on the
    same conversation therefore do not interleave their writes.
    """

    def __init__(
        self,
        transaction_scope: TransactionScope,
        interpreter: InterpretMessage,
        router: ReadOnlyQueryRouter,
        clock: Callable[[], datetime],
    ) -> None:
        self._transaction_scope = transaction_scope
        self._interpreter = interpreter
        self._router = router
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
        """Interpret a user message in an owned ACTIVE conversation and answer
        read-only queries.

        The user message is persisted only together with the turn's result, so
        a failed interpretation leaves no trace. The flow state is not changed.

        Raises ``ConversationNotFoundError`` when the conversation does not
        exist or is not owned by the customer, ``ConversationClosedError`` when
        it is CLOSED, and ``LLMUnavailableError`` or ``LLMInvalidResponseError``
        when the message cannot be interpreted.
        """
        if not content.strip():
            raise ValueError("message content must not be blank")
        self._now()  # A misconfigured clock fails before the LLM is called.

        with self._transaction_scope.begin() as repositories:
            _require_active(repositories, customer_id, conversation_id)

        interpretation = self._interpreter.execute(content)

        with self._transaction_scope.begin() as repositories:
            record = _require_active(repositories, customer_id, conversation_id)
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
            result = self._router.route(repositories, customer_id, interpretation, now)
        return Turn(
            conversation_id=conversation_id,
            flow_state=record.flow_state,
            message=message,
            intent=interpretation.intent,
            result=result,
        )

    def _now(self) -> datetime:
        now = self._clock()
        if now.tzinfo is None or now.utcoffset() is None:
            raise ValueError("clock must return a timezone-aware datetime")
        return now


def _require_active(
    repositories: Repositories, customer_id: UUID, conversation_id: UUID
) -> ConversationRecord:
    """Return the owned ACTIVE conversation, locked until the transaction ends."""
    record = repositories.conversations.get_for_update(customer_id, conversation_id)
    if record is None:
        raise ConversationNotFoundError()
    if record.conversation.status is ConversationStatus.CLOSED:
        raise ConversationClosedError()
    return record
