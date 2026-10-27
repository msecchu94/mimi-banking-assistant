"""HTTP models of the V1 Chat API contract.

They describe the wire format only: they are separate from Application and
Domain models and share only the domain vocabulary the contract exposes.
"""

from datetime import date
from decimal import Decimal
from enum import StrEnum
from typing import Annotated, Any, Literal
from uuid import UUID

from pydantic import (
    AfterValidator,
    AwareDatetime,
    BaseModel,
    ConfigDict,
    Discriminator,
    Field,
    PlainSerializer,
    StringConstraints,
    Tag,
    WithJsonSchema,
)

from mimi.domain.enums import (
    CardBrand,
    CardStatus,
    CardType,
    ConversationFlowState,
    Currency,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)


class _ChatModel(BaseModel):
    # Fields with defaults are always serialized, so responses declare them
    # required.
    model_config = ConfigDict(
        extra="forbid", json_schema_serialization_defaults_required=True
    )


class InteractionType(StrEnum):
    CONFIRM = "CONFIRM"
    CANCEL = "CANCEL"
    SELECT_CARD = "SELECT_CARD"


class IntentType(StrEnum):
    GET_BALANCE = "GET_BALANCE"
    GET_TRANSACTIONS = "GET_TRANSACTIONS"
    ANALYZE_EXPENSES = "ANALYZE_EXPENSES"
    COMPARE_EXPENSES = "COMPARE_EXPENSES"
    GET_CARDS = "GET_CARDS"
    FREEZE_CARD = "FREEZE_CARD"
    UNFREEZE_CARD = "UNFREEZE_CARD"
    GET_BENEFICIARIES = "GET_BENEFICIARIES"
    TRANSFER_MONEY = "TRANSFER_MONEY"
    GENERAL_CONVERSATION = "GENERAL_CONVERSATION"
    CANCEL = "CANCEL"
    UNKNOWN = "UNKNOWN"


class UiType(StrEnum):
    TEXT = "TEXT"
    CARD_LIST = "CARD_LIST"
    CARD_SELECTOR = "CARD_SELECTOR"
    BENEFICIARY_LIST = "BENEFICIARY_LIST"
    CONFIRMATION = "CONFIRMATION"
    EXPENSE_SUMMARY = "EXPENSE_SUMMARY"
    EXPENSE_COMPARISON = "EXPENSE_COMPARISON"
    TRANSACTION_LIST = "TRANSACTION_LIST"
    TRANSFER_SUMMARY = "TRANSFER_SUMMARY"


class ConfirmationActionType(StrEnum):
    CONFIRM = "CONFIRM"
    CANCEL = "CANCEL"


class ConfirmationSummaryType(StrEnum):
    TRANSFER = "TRANSFER"
    CARD = "CARD"


# Requests.

MessageText = Annotated[str, StringConstraints(pattern=r"\S")]
"""Free text that is not empty or whitespace only."""


class ConfirmPayload(_ChatModel):
    operation_id: UUID


class SelectCardPayload(_ChatModel):
    card_id: UUID


class MessageRequest(_ChatModel):
    conversation_id: UUID
    message: MessageText


class ConfirmRequest(_ChatModel):
    """Confirms only the operation waiting for confirmation under
    ``payload.operation_id``."""

    conversation_id: UUID
    interaction: Literal[InteractionType.CONFIRM]
    payload: ConfirmPayload


class CancelRequest(_ChatModel):
    conversation_id: UUID
    interaction: Literal[InteractionType.CANCEL]
    payload: None = None


class SelectCardRequest(_ChatModel):
    conversation_id: UUID
    interaction: Literal[InteractionType.SELECT_CARD]
    payload: SelectCardPayload


_MESSAGE = "MESSAGE"


def _request_kind(value: Any) -> str | None:
    """The variant of a request: its interaction, or a message without one.

    A request with an interaction is never a message request, so one that
    also carries a message is rejected by the interaction's variant.
    """
    if isinstance(value, dict):
        interaction = value.get("interaction")
        if interaction is not None:
            return str(interaction)
        return _MESSAGE if "message" in value else None
    if isinstance(value, MessageRequest):
        return _MESSAGE
    interaction = getattr(value, "interaction", None)
    return None if interaction is None else str(interaction)


ChatRequest = Annotated[
    Annotated[MessageRequest, Tag(_MESSAGE)]
    | Annotated[ConfirmRequest, Tag(InteractionType.CONFIRM)]
    | Annotated[CancelRequest, Tag(InteractionType.CANCEL)]
    | Annotated[SelectCardRequest, Tag(InteractionType.SELECT_CARD)],
    Discriminator(_request_kind),
]
"""Exactly one of a free-text message or a structured interaction, whose
payload is defined by its type."""


# Responses.

_CENT = Decimal("0.01")


def _in_cents(amount: Decimal) -> Decimal:
    if amount != amount.quantize(_CENT):
        raise ValueError("amount must have at most two decimal places")
    return amount


MoneyAmount = Annotated[
    Decimal,
    AfterValidator(_in_cents),
    PlainSerializer(lambda amount: f"{amount.quantize(_CENT):f}", return_type=str),
    WithJsonSchema({"type": "string", "pattern": r"^-?\d+\.\d{2}$"}),
]
"""A decimal amount carried as a string with exactly two decimal places."""


class Money(_ChatModel):
    amount: MoneyAmount
    currency: Currency


class CardItem(_ChatModel):
    id: UUID
    brand: CardBrand
    type: CardType
    last_four: str
    status: CardStatus


class BeneficiaryItem(_ChatModel):
    id: UUID
    name: str
    account_reference: str
    bank_name: str | None


class TransactionItem(_ChatModel):
    id: UUID
    description: str
    amount: Money
    type: TransactionType
    category: TransactionCategory
    occurred_at: AwareDatetime


class ExpensePeriod(_ChatModel):
    """A period of whole local days; ``to`` is its last day, inclusive."""

    model_config = ConfigDict(
        validate_by_name=True, validate_by_alias=True, serialize_by_alias=True
    )

    from_: date = Field(alias="from")
    to: date


class CategoryExpense(_ChatModel):
    category: TransactionCategory
    amount: Money


class CurrencyExpenses(_ChatModel):
    """Expenses in one currency; currencies are never combined or converted."""

    total: Money
    categories: list[CategoryExpense]


class ExpenseChange(StrEnum):
    INCREASE = "INCREASE"
    DECREASE = "DECREASE"
    UNCHANGED = "UNCHANGED"


def _non_negative(money: Money) -> Money:
    if money.amount < 0:
        raise ValueError("difference must be a non-negative magnitude")
    return money


class CurrencyComparison(_ChatModel):
    """The totals of one currency in both periods. ``difference`` is the
    non-negative magnitude of current minus previous; ``change`` carries its
    direction."""

    current_total: Money
    previous_total: Money
    difference: Annotated[Money, AfterValidator(_non_negative)]
    change: ExpenseChange


class ConfirmationAction(_ChatModel):
    type: ConfirmationActionType
    label: str


class TransferConfirmationSummary(_ChatModel):
    type: Literal[ConfirmationSummaryType.TRANSFER] = ConfirmationSummaryType.TRANSFER
    amount: Money
    beneficiary: str


class CardConfirmationSummary(_ChatModel):
    type: Literal[ConfirmationSummaryType.CARD] = ConfirmationSummaryType.CARD
    card: CardItem


ConfirmationSummary = Annotated[
    TransferConfirmationSummary | CardConfirmationSummary,
    Field(discriminator="type"),
]


class TextUiData(_ChatModel):
    pass


class CardListUiData(_ChatModel):
    cards: list[CardItem]


class CardSelectorUiData(_ChatModel):
    cards: list[CardItem]


class BeneficiaryListUiData(_ChatModel):
    beneficiaries: list[BeneficiaryItem]


class ConfirmationUiData(_ChatModel):
    operation_id: UUID
    title: str
    summary: ConfirmationSummary
    actions: list[ConfirmationAction]


class ExpenseSummaryUiData(_ChatModel):
    """One entry per currency with expenses; none when there were none."""

    period: ExpensePeriod
    currencies: list[CurrencyExpenses]


class ExpenseComparisonUiData(_ChatModel):
    current_period: ExpensePeriod
    previous_period: ExpensePeriod
    currencies: list[CurrencyComparison]


class TransactionListUiData(_ChatModel):
    transactions: list[TransactionItem]


class TransferSummaryUiData(_ChatModel):
    transfer_id: UUID
    beneficiary: str
    amount: Money
    status: TransferStatus
    executed_at: AwareDatetime


class TextUi(_ChatModel):
    type: Literal[UiType.TEXT] = UiType.TEXT
    data: TextUiData = TextUiData()


class CardListUi(_ChatModel):
    type: Literal[UiType.CARD_LIST] = UiType.CARD_LIST
    data: CardListUiData


class CardSelectorUi(_ChatModel):
    type: Literal[UiType.CARD_SELECTOR] = UiType.CARD_SELECTOR
    data: CardSelectorUiData


class BeneficiaryListUi(_ChatModel):
    type: Literal[UiType.BENEFICIARY_LIST] = UiType.BENEFICIARY_LIST
    data: BeneficiaryListUiData


class ConfirmationUi(_ChatModel):
    type: Literal[UiType.CONFIRMATION] = UiType.CONFIRMATION
    data: ConfirmationUiData


class ExpenseSummaryUi(_ChatModel):
    type: Literal[UiType.EXPENSE_SUMMARY] = UiType.EXPENSE_SUMMARY
    data: ExpenseSummaryUiData


class ExpenseComparisonUi(_ChatModel):
    type: Literal[UiType.EXPENSE_COMPARISON] = UiType.EXPENSE_COMPARISON
    data: ExpenseComparisonUiData


class TransactionListUi(_ChatModel):
    type: Literal[UiType.TRANSACTION_LIST] = UiType.TRANSACTION_LIST
    data: TransactionListUiData


class TransferSummaryUi(_ChatModel):
    type: Literal[UiType.TRANSFER_SUMMARY] = UiType.TRANSFER_SUMMARY
    data: TransferSummaryUiData


UiResponse = Annotated[
    TextUi
    | CardListUi
    | CardSelectorUi
    | BeneficiaryListUi
    | ConfirmationUi
    | ExpenseSummaryUi
    | ExpenseComparisonUi
    | TransactionListUi
    | TransferSummaryUi,
    Field(discriminator="type"),
]
"""One primary semantic UI representation, whose data is defined by its type."""


class ResponseMetadata(_ChatModel):
    request_id: str
    timestamp: AwareDatetime


class ChatResponse(_ChatModel):
    conversation_id: UUID
    message: str
    intent: IntentType
    conversation_state: ConversationFlowState
    ui: UiResponse
    metadata: ResponseMetadata


class ConversationResponse(_ChatModel):
    """A conversation started for the demo customer."""

    conversation_id: UUID
    conversation_state: ConversationFlowState
    metadata: ResponseMetadata
