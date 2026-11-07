"""Pre-validation of a complete pending operation.

The operation is checked against current financial state with the same rules
its Use Case applies on execution, so only an operation that is executable
now waits for confirmation. Passing does not authorize execution: the Use
Case revalidates after confirmation. Nothing is written.
"""

from collections.abc import Callable
from uuid import UUID

from mimi.application.conversation_results import (
    AwaitingConfirmationResult,
    PreValidationFailedResult,
)
from mimi.application.errors import ApplicationError, InvalidCardStateError
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingOperation,
    TransferOperationData,
    UnfreezeCardOperationData,
)
from mimi.application.repositories import Repositories
from mimi.application.use_cases.execute_transfer import validate_transfer
from mimi.application.use_cases.freeze_card import ensure_can_freeze
from mimi.application.use_cases.unfreeze_card import ensure_can_unfreeze
from mimi.domain.entities import Card


def pre_validate(
    repositories: Repositories, customer_id: UUID, operation: PendingOperation
) -> AwaitingConfirmationResult | PreValidationFailedResult:
    """Pre-validate ``operation``, which must be complete.

    The source account of a transfer is read locked, as on execution, until
    the caller's transaction ends.
    """
    if operation.missing_fields:
        raise ValueError("only a complete operation can be pre-validated")
    data = operation.data
    try:
        match data:
            case TransferOperationData(
                source_account_id=UUID() as source_account_id,
                beneficiary_id=UUID() as beneficiary_id,
                amount=amount,
            ) if amount is not None:
                account, beneficiary = validate_transfer(
                    repositories.accounts.get_for_update(
                        customer_id, source_account_id
                    ),
                    lambda: repositories.beneficiaries.get(customer_id, beneficiary_id),
                    amount,
                )
                return AwaitingConfirmationResult(
                    operation, source_account=account, beneficiary=beneficiary
                )
            case FreezeCardOperationData(card_id=UUID() as card_id):
                return _pre_validate_card(
                    operation,
                    repositories.cards.get(customer_id, card_id),
                    ensure_can_freeze,
                )
            case UnfreezeCardOperationData(card_id=UUID() as card_id):
                return _pre_validate_card(
                    operation,
                    repositories.cards.get(customer_id, card_id),
                    ensure_can_unfreeze,
                )
    except ApplicationError as error:
        return PreValidationFailedResult(operation, error)
    raise AssertionError("a complete operation has all its data")


def _pre_validate_card(
    operation: PendingOperation,
    card: Card | None,
    ensure: Callable[[Card | None], Card],
) -> AwaitingConfirmationResult | PreValidationFailedResult:
    """Check ``card`` with the Use Case's rule; a card in the wrong state is
    kept in the failure so the user can be told which card it is."""
    try:
        return AwaitingConfirmationResult(operation, card=ensure(card))
    except InvalidCardStateError as error:
        return PreValidationFailedResult(operation, error, card=card)
