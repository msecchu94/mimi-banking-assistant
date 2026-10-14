from uuid import UUID

from mimi.application.repositories import CardRepository
from mimi.domain.entities import Card


class GetCards:
    """Return the customer's cards with their persisted status.

    Cards are returned in repository order, frozen cards included. A customer
    without cards yields an empty list.
    """

    def __init__(self, cards: CardRepository) -> None:
        self._cards = cards

    def execute(self, customer_id: UUID) -> list[Card]:
        return self._cards.list_by_customer(customer_id)
