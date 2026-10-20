from dataclasses import replace
from uuid import UUID

from mimi.application.errors import CardNotFoundError, InvalidCardStateError
from mimi.application.repositories import CardRepository
from mimi.domain.entities import Card
from mimi.domain.enums import CardStatus


def ensure_can_unfreeze(card: Card | None) -> Card:
    """Check that an owned card, ``None`` when not found, can currently be
    unfrozen; raise the semantic error otherwise."""
    if card is None:
        raise CardNotFoundError()
    if card.status is not CardStatus.FROZEN:
        raise InvalidCardStateError()
    return card


class UnfreezeCard:
    """Unfreeze an owned FROZEN card and return it with its new status.

    Ownership and current status are validated on every execution, so calling
    it after confirmation revalidates the operation. The caller owns the
    transaction.
    """

    def __init__(self, cards: CardRepository) -> None:
        self._cards = cards

    def execute(self, customer_id: UUID, card_id: UUID) -> Card:
        card = ensure_can_unfreeze(self._cards.get(customer_id, card_id))

        self._cards.update_status(card.id, CardStatus.ACTIVE)
        return replace(card, status=CardStatus.ACTIVE)
