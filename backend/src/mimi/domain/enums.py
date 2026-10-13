from enum import StrEnum


class Currency(StrEnum):
    ARS = "ARS"
    USD = "USD"


class AccountStatus(StrEnum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"


class CardType(StrEnum):
    DEBIT = "DEBIT"
    CREDIT = "CREDIT"


class CardBrand(StrEnum):
    VISA = "VISA"
    MASTERCARD = "MASTERCARD"


class CardStatus(StrEnum):
    ACTIVE = "ACTIVE"
    FROZEN = "FROZEN"


class TransactionType(StrEnum):
    DEBIT = "DEBIT"
    CREDIT = "CREDIT"


class TransactionCategory(StrEnum):
    GROCERIES = "GROCERIES"
    DINING = "DINING"
    TRANSPORT = "TRANSPORT"
    FUEL = "FUEL"
    UTILITIES = "UTILITIES"
    SUBSCRIPTIONS = "SUBSCRIPTIONS"
    ENTERTAINMENT = "ENTERTAINMENT"
    SHOPPING = "SHOPPING"
    TRANSFER = "TRANSFER"
    OTHER = "OTHER"


class TransferStatus(StrEnum):
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"


class ConversationStatus(StrEnum):
    ACTIVE = "ACTIVE"
    CLOSED = "CLOSED"


class ConversationFlowState(StrEnum):
    READY = "READY"
    COLLECTING_DATA = "COLLECTING_DATA"
    WAITING_CONFIRMATION = "WAITING_CONFIRMATION"


class PendingOperationType(StrEnum):
    TRANSFER = "TRANSFER"
    FREEZE_CARD = "FREEZE_CARD"
    UNFREEZE_CARD = "UNFREEZE_CARD"


class MessageRole(StrEnum):
    USER = "USER"
    ASSISTANT = "ASSISTANT"
