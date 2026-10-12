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
