from typing import ClassVar


class ApplicationError(Exception):
    """Base class for semantic application errors.

    Category subclasses describe the kind of failure. Concrete subclasses of a
    category define the stable public ``code`` and a safe ``default_message``.
    """

    code: ClassVar[str]
    default_message: ClassVar[str]

    def __init__(self, message: str | None = None) -> None:
        cls = type(self)
        if not hasattr(cls, "code") or not hasattr(cls, "default_message"):
            raise TypeError(
                f"{cls.__name__} is an error category; raise a concrete subclass"
            )
        self.message = message or cls.default_message
        super().__init__(self.message)


class NotFoundError(ApplicationError):
    """A requested resource does not exist."""


class ConflictError(ApplicationError):
    """The request conflicts with the current resource or conversation state."""


class BusinessRuleViolationError(ApplicationError):
    """The request is understood but violates a validation or business rule."""


class DependencyUnavailableError(ApplicationError):
    """A required external dependency is temporarily unavailable."""


class CardNotFoundError(NotFoundError):
    code = "CARD_NOT_FOUND"
    default_message = "The requested card was not found."


class InvalidCardStateError(ConflictError):
    code = "INVALID_CARD_STATE"
    default_message = "The card's current state does not allow this operation."


class BeneficiaryNotFoundError(NotFoundError):
    code = "BENEFICIARY_NOT_FOUND"
    default_message = "The requested beneficiary was not found."


class AccountNotFoundError(NotFoundError):
    code = "ACCOUNT_NOT_FOUND"
    default_message = "The requested account was not found."


class InvalidAccountStateError(ConflictError):
    code = "INVALID_ACCOUNT_STATE"
    default_message = "The account's current state does not allow this operation."


class InvalidAmountError(BusinessRuleViolationError):
    code = "INVALID_AMOUNT"
    default_message = "The amount is not valid for this operation."


class InsufficientFundsError(BusinessRuleViolationError):
    code = "INSUFFICIENT_FUNDS"
    default_message = "The account does not have sufficient funds."


class ConversationNotFoundError(NotFoundError):
    code = "CONVERSATION_NOT_FOUND"
    default_message = "The requested conversation was not found."


class ConversationClosedError(ConflictError):
    code = "CONVERSATION_CLOSED"
    default_message = "The conversation is closed and cannot continue."


# LLM failures share the public SERVICE_UNAVAILABLE code: the client cannot act
# differently on them, so the distinction stays internal.


class LLMUnavailableError(DependencyUnavailableError):
    code = "SERVICE_UNAVAILABLE"
    default_message = "The service is temporarily unavailable."


class LLMInvalidResponseError(DependencyUnavailableError):
    code = "SERVICE_UNAVAILABLE"
    default_message = "The service is temporarily unavailable."
