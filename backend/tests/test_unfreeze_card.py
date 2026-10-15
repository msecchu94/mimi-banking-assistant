from dataclasses import replace
from uuid import UUID, uuid4

import pytest

from mimi.application.errors import (
    CardNotFoundError,
    ConflictError,
    InvalidCardStateError,
    NotFoundError,
)
from mimi.application.use_cases.get_cards import GetCards
from mimi.application.use_cases.unfreeze_card import UnfreezeCard
from mimi.domain.entities import Card
from mimi.domain.enums import CardBrand, CardStatus, CardType

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()
ACCOUNT_ID = uuid4()
OTHER_ACCOUNT_ID = uuid4()
ACCOUNT_OWNERS = {ACCOUNT_ID: CUSTOMER_ID, OTHER_ACCOUNT_ID: OTHER_CUSTOMER_ID}


class FakeCardRepository:
    def __init__(self, cards: list[Card]) -> None:
        self._cards = {card.id: card for card in cards}
        self.status_updates: list[tuple[UUID, CardStatus]] = []

    def list_by_customer(self, customer_id: UUID) -> list[Card]:
        return [
            c
            for c in self._cards.values()
            if ACCOUNT_OWNERS[c.account_id] == customer_id
        ]

    def get(self, customer_id: UUID, card_id: UUID) -> Card | None:
        card = self._cards.get(card_id)
        if card is None or ACCOUNT_OWNERS[card.account_id] != customer_id:
            return None
        return card

    def update_status(self, card_id: UUID, status: CardStatus) -> None:
        self.status_updates.append((card_id, status))
        self._cards[card_id] = replace(self._cards[card_id], status=status)


def make_card(
    *,
    status: CardStatus = CardStatus.FROZEN,
    account_id: UUID = ACCOUNT_ID,
) -> Card:
    return Card(
        id=uuid4(),
        account_id=account_id,
        type=CardType.DEBIT,
        brand=CardBrand.VISA,
        last_four="4242",
        status=status,
    )


def test_unfreezes_frozen_card() -> None:
    card = make_card()
    cards = FakeCardRepository([card])

    result = UnfreezeCard(cards).execute(CUSTOMER_ID, card.id)

    assert result == replace(card, status=CardStatus.ACTIVE)
    assert cards.status_updates == [(card.id, CardStatus.ACTIVE)]


def test_active_state_is_observable_by_card_query() -> None:
    card = make_card()
    cards = FakeCardRepository([card])

    UnfreezeCard(cards).execute(CUSTOMER_ID, card.id)

    assert GetCards(cards).execute(CUSTOMER_ID) == [
        replace(card, status=CardStatus.ACTIVE)
    ]


def test_leaves_other_cards_unchanged() -> None:
    card = make_card()
    other = make_card()
    cards = FakeCardRepository([card, other])

    UnfreezeCard(cards).execute(CUSTOMER_ID, card.id)

    assert cards.get(CUSTOMER_ID, other.id) == other


def test_rejects_already_active_card_without_mutation() -> None:
    card = make_card(status=CardStatus.ACTIVE)
    cards = FakeCardRepository([card])

    with pytest.raises(InvalidCardStateError) as exc_info:
        UnfreezeCard(cards).execute(CUSTOMER_ID, card.id)

    assert isinstance(exc_info.value, ConflictError)
    assert exc_info.value.code == "INVALID_CARD_STATE"
    assert cards.status_updates == []
    assert cards.get(CUSTOMER_ID, card.id) == card


def test_rejects_unknown_card_without_mutation() -> None:
    cards = FakeCardRepository([make_card()])

    with pytest.raises(CardNotFoundError) as exc_info:
        UnfreezeCard(cards).execute(CUSTOMER_ID, uuid4())

    assert isinstance(exc_info.value, NotFoundError)
    assert exc_info.value.code == "CARD_NOT_FOUND"
    assert cards.status_updates == []


def test_rejects_card_owned_by_another_customer_without_mutation() -> None:
    other = make_card(account_id=OTHER_ACCOUNT_ID)
    cards = FakeCardRepository([other])

    with pytest.raises(CardNotFoundError):
        UnfreezeCard(cards).execute(CUSTOMER_ID, other.id)

    assert cards.status_updates == []
    assert cards.get(OTHER_CUSTOMER_ID, other.id) == other
