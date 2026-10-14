from uuid import UUID, uuid4

from mimi.application.use_cases.get_cards import GetCards
from mimi.domain.entities import Card
from mimi.domain.enums import CardBrand, CardStatus, CardType

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()
ACCOUNT_ID = uuid4()
OTHER_ACCOUNT_ID = uuid4()
ACCOUNT_OWNERS = {ACCOUNT_ID: CUSTOMER_ID, OTHER_ACCOUNT_ID: OTHER_CUSTOMER_ID}


class FakeCardRepository:
    def __init__(self, cards: list[Card]) -> None:
        self._cards = cards

    def list_by_customer(self, customer_id: UUID) -> list[Card]:
        return [c for c in self._cards if ACCOUNT_OWNERS[c.account_id] == customer_id]

    def get(self, customer_id: UUID, card_id: UUID) -> Card | None:
        raise AssertionError("card query must not read single cards")

    def update_status(self, card_id: UUID, status: CardStatus) -> None:
        raise AssertionError("card query must not modify cards")


def make_card(
    *,
    type: CardType = CardType.DEBIT,
    brand: CardBrand = CardBrand.VISA,
    last_four: str = "4242",
    status: CardStatus = CardStatus.ACTIVE,
    account_id: UUID = ACCOUNT_ID,
) -> Card:
    return Card(
        id=uuid4(),
        account_id=account_id,
        type=type,
        brand=brand,
        last_four=last_four,
        status=status,
    )


def get_cards(cards: list[Card], customer_id: UUID = CUSTOMER_ID) -> list[Card]:
    return GetCards(FakeCardRepository(cards)).execute(customer_id)


def test_returns_single_card_with_its_status() -> None:
    card = make_card()

    result = get_cards([card])

    assert result == [card]
    assert result[0].status is CardStatus.ACTIVE


def test_returns_multiple_cards_in_repository_order() -> None:
    visa = make_card(brand=CardBrand.VISA, last_four="9999")
    mastercard = make_card(
        type=CardType.CREDIT, brand=CardBrand.MASTERCARD, last_four="1111"
    )

    assert get_cards([visa, mastercard]) == [visa, mastercard]


def test_includes_frozen_card_with_its_status() -> None:
    card = make_card(status=CardStatus.FROZEN)

    result = get_cards([card])

    assert result == [card]
    assert result[0].status is CardStatus.FROZEN


def test_returns_empty_list_when_customer_has_no_cards() -> None:
    other = make_card(account_id=OTHER_ACCOUNT_ID)

    assert get_cards([other]) == []


def test_returns_only_the_requested_customers_cards() -> None:
    own = make_card()
    other = make_card(account_id=OTHER_ACCOUNT_ID)

    assert get_cards([own, other]) == [own]
