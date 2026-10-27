from collections.abc import Callable
from dataclasses import dataclass, replace
from datetime import datetime
from uuid import UUID, uuid4

from mimi.application.conversation_context import EMPTY_CONTEXT, ConversationContext
from mimi.application.conversation_results import (
    AwaitingConfirmationResult,
    CollectingDataResult,
    NoPendingOperationResult,
    OperationCancelledResult,
    OperationCompletedResult,
    OperationFailedResult,
    PendingOperationConflictResult,
    TurnResult,
)
from mimi.application.errors import (
    ApplicationError,
    ConversationClosedError,
    ConversationNotFoundError,
    InvalidConversationStateError,
    InvalidInteractionError,
)
from mimi.application.interactions import Cancel, Interaction, SelectCard
from mimi.application.interpretation import (
    CollectionInput,
    FollowUp,
    Intent,
    Interpretation,
)
from mimi.application.operation_collection import collect_operation, select_card
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingOperation,
    PendingOperationData,
    TransferOperationData,
    UnfreezeCardOperationData,
)
from mimi.application.pre_validation import pre_validate
from mimi.application.read_only_queries import ReadOnlyQueryRouter
from mimi.application.repositories import (
    ConversationRecord,
    Repositories,
    TransactionScope,
)
from mimi.application.use_cases.execute_transfer import ExecuteTransfer
from mimi.application.use_cases.freeze_card import FreezeCard
from mimi.application.use_cases.interpret_message import (
    InterpretCollectionInput,
    InterpretMessage,
)
from mimi.application.use_cases.unfreeze_card import UnfreezeCard
from mimi.domain.entities import Conversation, Message
from mimi.domain.enums import (
    ConversationFlowState,
    ConversationStatus,
    MessageRole,
    PendingOperationType,
)

_OPERATION_TYPES = {
    Intent.TRANSFER_MONEY: PendingOperationType.TRANSFER,
    Intent.FREEZE_CARD: PendingOperationType.FREEZE_CARD,
    Intent.UNFREEZE_CARD: PendingOperationType.UNFREEZE_CARD,
}
_OPERATION_INTENTS = {
    operation_type: intent for intent, operation_type in _OPERATION_TYPES.items()
}


@dataclass(frozen=True)
class Turn:
    """Outcome of handling one user message or structured interaction.

    ``intent`` is the effective intent: a resolved follow-up reports the intent
    it continued, and data collected for, or a confirmation of, the pending
    operation reports that operation's intent. ``flow_state`` is the state
    after the turn. ``message`` is the persisted user message; an interaction
    persists none.
    """

    conversation_id: UUID
    flow_state: ConversationFlowState
    message: Message | None
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
        collection_interpreter: InterpretCollectionInput,
        router: ReadOnlyQueryRouter,
        clock: Callable[[], datetime],
    ) -> None:
        self._transaction_scope = transaction_scope
        self._interpreter = interpreter
        self._collection_interpreter = collection_interpreter
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

    def close(self, customer_id: UUID, conversation_id: UUID) -> ConversationRecord:
        """Close an owned ACTIVE conversation and return it.

        Any pending operation is discarded without being executed, and the
        context is cleared; messages are kept. Raises
        ``ConversationNotFoundError`` when the conversation does not exist or is
        not owned by the customer, and ``ConversationClosedError`` when it is
        already CLOSED.
        """
        with self._transaction_scope.begin() as repositories:
            record = _require_active(repositories, customer_id, conversation_id)
            now = self._now()
            conversations = repositories.conversations
            conversations.save_pending_operation(
                conversation_id, ConversationFlowState.READY, None
            )
            conversations.save_context(conversation_id, EMPTY_CONTEXT)
            conversations.mark_closed(conversation_id)
            conversations.touch(conversation_id, now)
        return ConversationRecord(
            conversation=replace(
                record.conversation, status=ConversationStatus.CLOSED, updated_at=now
            ),
            flow_state=ConversationFlowState.READY,
        )

    def handle_message(
        self, customer_id: UUID, conversation_id: UUID, content: str
    ) -> Turn:
        """Interpret a user message in an owned ACTIVE conversation, answer
        read-only queries, including follow-ups of the previous query, and
        collect or correct the data of a state-changing operation.

        While an operation is pending, the message is first interpreted as data
        for it, including corrections while it waits for confirmation; any
        other message is interpreted on its own, and so is a reply stating no
        data for an operation waiting for confirmation. A state-changing
        request starts collecting from READY, and a request of the pending
        operation's type is merged into it; a request of another type is a
        conflict and the pending operation is unchanged. Collected data that
        completes the operation is pre-validated: a valid operation waits for
        confirmation under a new ``operation_id``, which invalidates any earlier
        confirmation request, and an invalid one is discarded, returning to
        READY. Corrected data that leaves the operation incomplete returns it
        to COLLECTING_DATA. Nothing is executed.

        The user message is persisted only together with the turn's result, so
        a failed interpretation leaves no trace. A follow-up is resolved against
        the context read under the turn lock. Only an executed read-only query
        replaces the conversation's context; any other turn leaves it unchanged.

        Raises ``ConversationNotFoundError`` when the conversation does not
        exist or is not owned by the customer, ``ConversationClosedError`` when
        it is CLOSED, ``InvalidConversationStateError`` when the pending
        operation changed while the message was interpreted, and
        ``LLMUnavailableError`` or ``LLMInvalidResponseError`` when the message
        cannot be interpreted.
        """
        if not content.strip():
            raise ValueError("message content must not be blank")
        self._now()  # A misconfigured clock fails before the LLM is called.

        with self._transaction_scope.begin() as repositories:
            pending = _require_active(
                repositories, customer_id, conversation_id
            ).pending_operation

        interpretation = self._interpret(content, pending)

        with self._transaction_scope.begin() as repositories:
            record = _require_active(repositories, customer_id, conversation_id)
            if record.pending_operation != pending:
                raise InvalidConversationStateError()
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
            flow_state = record.flow_state
            if isinstance(interpretation, CollectionInput):
                if pending is None:
                    raise AssertionError("collection input without an operation")
                intent = _OPERATION_INTENTS[pending.type]
                result, flow_state = self._collect(
                    repositories,
                    customer_id,
                    conversation_id,
                    pending.type,
                    pending.data,
                    interpretation,
                )
            elif (
                isinstance(interpretation, Interpretation)
                and interpretation.intent in _OPERATION_TYPES
            ):
                intent = interpretation.intent
                result, flow_state = self._request_operation(
                    repositories, customer_id, record, interpretation
                )
            else:
                if isinstance(interpretation, FollowUp):
                    resolved = self._router.resolve_follow_up(
                        interpretation, record.context, now
                    )
                else:
                    resolved = interpretation
                query = (
                    self._router.prepare(resolved)
                    if isinstance(resolved, Interpretation)
                    else resolved
                )
                intent = query.intent
                if isinstance(query, Interpretation):
                    result = self._router.execute(repositories, customer_id, query, now)
                    repositories.conversations.save_context(
                        conversation_id, ConversationContext.after_query(query, now)
                    )
                else:
                    result = query
        return Turn(
            conversation_id=conversation_id,
            flow_state=flow_state,
            message=message,
            intent=intent,
            result=result,
        )

    def handle_interaction(
        self, customer_id: UUID, conversation_id: UUID, interaction: Interaction
    ) -> Turn:
        """Apply a structured interaction to an owned ACTIVE conversation,
        without interpreting it.

        ``CONFIRM`` executes the operation waiting for confirmation, exactly as
        persisted, with its Use Case, which revalidates it against current
        state first; a revalidation failure discards it without executing it.
        It applies only to the confirmation request it names: another
        ``operation_id`` is an ``InvalidInteractionError``.
        ``CANCEL`` discards the pending operation without executing it. Either
        way the conversation returns to READY. Without a pending operation,
        both have no effect. ``SELECT_CARD`` sets the card of the card
        operation being collected, which is then pre-validated as collected
        data is.

        The turn runs in one transaction under the conversation lock, persists
        no message and leaves the context unchanged.

        Raises ``ConversationNotFoundError``, ``ConversationClosedError``, and
        ``InvalidInteractionError`` when the interaction does not apply to the
        current flow state or pending operation, leaving the conversation
        unchanged.
        """
        with self._transaction_scope.begin() as repositories:
            record = _require_active(repositories, customer_id, conversation_id)
            now = self._now()
            pending = record.pending_operation
            flow_state = ConversationFlowState.READY
            result: TurnResult
            if isinstance(interaction, SelectCard):
                operation = _collecting(record)
                if operation is None or operation.type is PendingOperationType.TRANSFER:
                    raise InvalidInteractionError()
                intent = _OPERATION_INTENTS[operation.type]
                result, flow_state = self._save_collected(
                    repositories,
                    customer_id,
                    conversation_id,
                    select_card(
                        repositories, customer_id, operation.type, interaction.card_id
                    ),
                )
            elif pending is None:
                intent = (
                    Intent.CANCEL if isinstance(interaction, Cancel) else Intent.UNKNOWN
                )
                result = NoPendingOperationResult(interaction)
            elif isinstance(interaction, Cancel):
                intent = Intent.CANCEL
                result = OperationCancelledResult(pending)
                repositories.conversations.save_pending_operation(
                    conversation_id, flow_state, None
                )
            elif record.flow_state is ConversationFlowState.WAITING_CONFIRMATION:
                if interaction.operation_id != pending.operation_id:
                    raise InvalidInteractionError()
                intent = _OPERATION_INTENTS[pending.type]
                result = _execute(repositories, customer_id, pending, now)
                repositories.conversations.save_pending_operation(
                    conversation_id, flow_state, None
                )
            else:
                raise InvalidInteractionError()
            repositories.conversations.touch(conversation_id, now)
        return Turn(
            conversation_id=conversation_id,
            flow_state=flow_state,
            message=None,
            intent=intent,
            result=result,
        )

    def _interpret(
        self, content: str, pending: PendingOperation | None
    ) -> Interpretation | FollowUp | CollectionInput:
        if pending is not None:
            collected = self._collection_interpreter.execute(
                content, pending.type, pending.missing_fields
            )
            # A reply stating no data does not correct an operation waiting
            # for confirmation, so its confirmation request stays valid.
            if collected is not None and not (
                pending.operation_id is not None and collected == CollectionInput()
            ):
                return collected
        return self._interpreter.execute(content)

    def _request_operation(
        self,
        repositories: Repositories,
        customer_id: UUID,
        record: ConversationRecord,
        interpretation: Interpretation,
    ) -> tuple[TurnResult, ConversationFlowState]:
        """Start collecting a requested operation, or merge the request into
        the pending operation of the same type, collected or waiting for
        confirmation."""
        operation_type = _OPERATION_TYPES[interpretation.intent]
        pending = record.pending_operation
        if pending is not None and pending.type is not operation_type:
            conflict = PendingOperationConflictResult(
                interpretation.intent, pending.type
            )
            return conflict, record.flow_state
        return self._collect(
            repositories,
            customer_id,
            record.conversation.id,
            operation_type,
            None if pending is None else pending.data,
            CollectionInput.from_interpretation(interpretation),
        )

    def _collect(
        self,
        repositories: Repositories,
        customer_id: UUID,
        conversation_id: UUID,
        operation_type: PendingOperationType,
        data: PendingOperationData | None,
        stated: CollectionInput,
    ) -> tuple[TurnResult, ConversationFlowState]:
        """Merge ``stated`` into the operation and save its resulting state."""
        return self._save_collected(
            repositories,
            customer_id,
            conversation_id,
            collect_operation(repositories, customer_id, operation_type, data, stated),
        )

    def _save_collected(
        self,
        repositories: Repositories,
        customer_id: UUID,
        conversation_id: UUID,
        collection: CollectingDataResult,
    ) -> tuple[TurnResult, ConversationFlowState]:
        """Save the collected operation: still collecting while data is
        missing, otherwise waiting for confirmation under a new
        ``operation_id`` once pre-validated, or discarded when pre-validation
        fails."""
        operation: PendingOperation | None = collection.operation
        result: TurnResult = collection
        if collection.operation.missing_fields:
            flow_state = ConversationFlowState.COLLECTING_DATA
        else:
            result = pre_validate(repositories, customer_id, collection.operation)
            if isinstance(result, AwaitingConfirmationResult):
                flow_state = ConversationFlowState.WAITING_CONFIRMATION
                operation = replace(collection.operation, operation_id=uuid4())
                result = replace(result, operation=operation)
            else:
                flow_state = ConversationFlowState.READY
                operation = None
        repositories.conversations.save_pending_operation(
            conversation_id, flow_state, operation
        )
        return result, flow_state

    def _now(self) -> datetime:
        now = self._clock()
        if now.tzinfo is None or now.utcoffset() is None:
            raise ValueError("clock must return a timezone-aware datetime")
        return now


def _execute(
    repositories: Repositories,
    customer_id: UUID,
    operation: PendingOperation,
    now: datetime,
) -> OperationCompletedResult | OperationFailedResult:
    """Execute a confirmed operation with its Use Case, which revalidates it
    against current state and raises before any write when it fails."""
    try:
        match operation.data:
            case TransferOperationData(
                source_account_id=UUID() as source_account_id,
                beneficiary_id=UUID() as beneficiary_id,
                amount=amount,
            ) if amount is not None:
                executed = ExecuteTransfer(
                    repositories.accounts,
                    repositories.beneficiaries,
                    repositories.transfers,
                    lambda: now,
                ).execute(
                    customer_id=customer_id,
                    source_account_id=source_account_id,
                    beneficiary_id=beneficiary_id,
                    amount=amount,
                )
                return OperationCompletedResult(
                    operation,
                    transfer=executed.transfer,
                    beneficiary=executed.beneficiary,
                )
            case FreezeCardOperationData(card_id=UUID() as card_id):
                card = FreezeCard(repositories.cards).execute(customer_id, card_id)
                return OperationCompletedResult(operation, card=card)
            case UnfreezeCardOperationData(card_id=UUID() as card_id):
                card = UnfreezeCard(repositories.cards).execute(customer_id, card_id)
                return OperationCompletedResult(operation, card=card)
    except ApplicationError as error:
        return OperationFailedResult(operation, error)
    raise AssertionError("an operation waiting for confirmation is complete")


def _collecting(record: ConversationRecord) -> PendingOperation | None:
    """The operation whose data is being collected, if any."""
    if record.flow_state is ConversationFlowState.COLLECTING_DATA:
        return record.pending_operation
    return None


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
