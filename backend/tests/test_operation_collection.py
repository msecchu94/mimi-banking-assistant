from dataclasses import dataclass, field
from decimal import Decimal
from typing import Any
from uuid import UUID, uuid4

import pytest

from mimi.application.conversation_results import (
    AmountCurrencyConflict,
    CollectingDataResult,
    FieldIssue,
)
from mimi.application.interpretation import CollectionInput
from mimi.application.operation_collection import (
    collect_operation,
    match_accounts,
    match_beneficiaries,
    match_cards,
)
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingField,
    PendingOperation,
    PendingOperationData,
    TransferOperationData,
    UnfreezeCardOperationData,
)
from mimi.domain.entities import Account, Beneficiary, Card, Money
from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    Currency,
    PendingOperationType,
)

CUSTOMER_ID = uuid4()
TRANSFER = PendingOperationType.TRANSFER


def account(name: str, currency: Currency, **changes: Any) -> Account:
    fields: dict[str, Any] = {
        "id": uuid4(),
        "customer_id": CUSTOMER_ID,
        "name": name,
        "balance": Money(Decimal("100000.00"), currency),
        "status": AccountStatus.ACTIVE,
        **changes,
    }
    return Account(**fields)


def beneficiary(name: str) -> Beneficiary:
    return Beneficiary(uuid4(), CUSTOMER_ID, name, "0000003100012345678901", None)


def card(card_type: CardType, brand: CardBrand, last_four: str) -> Card:
    return Card(uuid4(), uuid4(), card_type, brand, last_four, CardStatus.ACTIVE)


PESOS = account("Cuenta principal", Currency.ARS)
DOLLARS = account("Caja de ahorro en dólares", Currency.USD)
INACTIVE_PESOS = account("Cuenta vieja", Currency.ARS, status=AccountStatus.INACTIVE)

LAURA = beneficiary("Laura Gómez")
CARLOS = beneficiary("Carlos Díaz")
JUAN_PEREZ = beneficiary("Juan Pérez")
JUAN_GARCIA = beneficiary("Juan García")
JUAN = beneficiary("Juan")

VISA_DEBIT = card(CardType.DEBIT, CardBrand.VISA, "4821")
VISA_CREDIT = card(CardType.CREDIT, CardBrand.VISA, "9134")
MASTERCARD = card(CardType.CREDIT, CardBrand.MASTERCARD, "5562")


def ars(amount: str) -> Money:
    return Money(Decimal(amount), Currency.ARS)


def usd(amount: str) -> Money:
    return Money(Decimal(amount), Currency.USD)


class Records[T]:
    def __init__(self, records: list[T]) -> None:
        self.records = records

    def list_by_customer(self, customer_id: UUID) -> list[T]:
        return list(self.records) if customer_id == CUSTOMER_ID else []


@dataclass
class FakeRepositories:
    """Only the reads data collection uses."""

    accounts: Any = field(default_factory=lambda: Records([PESOS, DOLLARS]))
    beneficiaries: Any = field(
        default_factory=lambda: Records([LAURA, CARLOS, JUAN_PEREZ, JUAN_GARCIA])
    )
    cards: Any = field(
        default_factory=lambda: Records([VISA_DEBIT, VISA_CREDIT, MASTERCARD])
    )
    transactions: Any = None
    conversations: Any = None
    messages: Any = None


def collect(
    stated: CollectionInput,
    data: PendingOperationData | None = None,
    *,
    operation_type: PendingOperationType = TRANSFER,
    repositories: FakeRepositories | None = None,
) -> CollectingDataResult:
    return collect_operation(
        repositories or FakeRepositories(), CUSTOMER_ID, operation_type, data, stated
    )


def transfer(result: CollectingDataResult) -> TransferOperationData:
    assert isinstance(result.operation.data, TransferOperationData)
    return result.operation.data


# Matching.


@pytest.mark.parametrize(
    ("reference", "expected"),
    [
        ("Laura", (LAURA,)),
        ("laura gomez", (LAURA,)),
        ("a Laura", (LAURA,)),
        ("LAURA GÓMEZ", (LAURA,)),
        ("Juan", (JUAN_PEREZ, JUAN_GARCIA)),
        ("Juan Pérez", (JUAN_PEREZ,)),
        ("Pérez Juan", (JUAN_PEREZ,)),
        ("mi hermana", ()),
        ("Lau", ()),
        ("mi", ()),
    ],
)
def test_beneficiaries_match_every_stated_word(
    reference: str, expected: tuple[Beneficiary, ...]
) -> None:
    beneficiaries = [LAURA, CARLOS, JUAN_PEREZ, JUAN_GARCIA]

    assert match_beneficiaries(reference, beneficiaries) == expected


def test_exact_beneficiary_name_excludes_partial_matches() -> None:
    assert match_beneficiaries("Juan", [JUAN_PEREZ, JUAN, JUAN_GARCIA]) == (JUAN,)


@pytest.mark.parametrize(
    ("reference", "expected"),
    [
        ("my Visa", (VISA_DEBIT, VISA_CREDIT)),
        ("la Visa de débito", (VISA_DEBIT,)),
        ("the credit card", (VISA_CREDIT, MASTERCARD)),
        ("la Master", (MASTERCARD,)),
        ("la que termina en 9134", (VISA_CREDIT,)),
        ("ending in 34", (VISA_CREDIT,)),
        ("mi tarjeta", (VISA_DEBIT, VISA_CREDIT, MASTERCARD)),
        ("la Mastercard de débito", ()),
        ("la que termina en 0000", ()),
        ("la que termina en 194821", ()),
    ],
)
def test_cards_match_brand_type_and_trailing_digits(
    reference: str, expected: tuple[Card, ...]
) -> None:
    assert match_cards(reference, [VISA_DEBIT, VISA_CREDIT, MASTERCARD]) == expected


@pytest.mark.parametrize(
    ("reference", "currency", "expected"),
    [
        ("la cuenta en dólares", None, (DOLLARS,)),
        ("my dollar account", None, (DOLLARS,)),
        ("la cuenta principal", None, (PESOS,)),
        ("mi caja de ahorro", None, (DOLLARS,)),
        ("la cuenta en pesos", None, (PESOS, INACTIVE_PESOS)),
        ("la cuenta", Currency.ARS, (PESOS, INACTIVE_PESOS)),
        ("la cuenta principal", Currency.USD, ()),
        ("la cuenta de inversiones", None, ()),
        (None, Currency.USD, (DOLLARS,)),
        (None, None, (PESOS, DOLLARS, INACTIVE_PESOS)),
    ],
)
def test_accounts_match_name_words_and_currency(
    reference: str | None, currency: Currency | None, expected: tuple[Account, ...]
) -> None:
    accounts = [PESOS, DOLLARS, INACTIVE_PESOS]

    assert match_accounts(reference, accounts, currency) == expected


# Merging stated data.


def test_unstated_fields_keep_their_value() -> None:
    data = TransferOperationData(PESOS.id, LAURA.id)

    result = collect(CollectionInput(), data)

    assert result == CollectingDataResult(PendingOperation(TRANSFER, data))


def test_resolved_correction_replaces_the_previous_value() -> None:
    result = collect(
        CollectionInput(beneficiary_reference="Carlos"),
        TransferOperationData(PESOS.id, LAURA.id, ars("100")),
    )

    assert transfer(result) == TransferOperationData(PESOS.id, CARLOS.id, ars("100"))
    assert result.issues == {}


@pytest.mark.parametrize(
    ("stated", "issue", "candidates"),
    [
        (CollectionInput(beneficiary_reference="Juan"), FieldIssue.AMBIGUOUS, 2),
        (CollectionInput(beneficiary_reference="Pedro"), FieldIssue.NOT_FOUND, 0),
        (
            CollectionInput(invalid_fields=frozenset({"beneficiary_reference"})),
            FieldIssue.INVALID,
            0,
        ),
    ],
)
def test_failed_correction_clears_the_previous_value(
    stated: CollectionInput, issue: FieldIssue, candidates: int
) -> None:
    result = collect(stated, TransferOperationData(PESOS.id, LAURA.id, ars("100")))

    assert transfer(result) == TransferOperationData(PESOS.id, None, ars("100"))
    assert result.issues == {PendingField.BENEFICIARY_ID: issue}
    assert len(result.beneficiary_candidates) == candidates


def test_failed_field_does_not_discard_independent_data() -> None:
    result = collect(
        CollectionInput(amount=Decimal("25000"), beneficiary_reference="Juan"),
        TransferOperationData(PESOS.id, LAURA.id),
    )

    assert transfer(result) == TransferOperationData(PESOS.id, None, ars("25000"))
    assert result.issues == {PendingField.BENEFICIARY_ID: FieldIssue.AMBIGUOUS}
    assert result.beneficiary_candidates == (JUAN_PEREZ, JUAN_GARCIA)


def test_missing_fields_stay_derived_from_the_data() -> None:
    result = collect(CollectionInput(beneficiary_reference="Laura"))

    assert result.operation.missing_fields == (
        PendingField.SOURCE_ACCOUNT_ID,
        PendingField.AMOUNT,
    )


# Source account.


def test_source_account_is_the_only_account_without_a_default() -> None:
    single = FakeRepositories(accounts=Records([PESOS]))

    assert transfer(collect(CollectionInput(), repositories=single)) == (
        TransferOperationData(PESOS.id)
    )
    assert transfer(collect(CollectionInput())) == TransferOperationData()


def test_source_account_is_selected_by_reference() -> None:
    result = collect(CollectionInput(account_reference="la cuenta en dólares"))

    assert transfer(result).source_account_id == DOLLARS.id


@pytest.mark.parametrize(
    ("reference", "issue", "candidates"),
    [
        ("la cuenta", FieldIssue.AMBIGUOUS, (PESOS, DOLLARS)),
        ("la cuenta de inversiones", FieldIssue.NOT_FOUND, ()),
    ],
)
def test_unresolved_account_reference_clears_the_source_account(
    reference: str, issue: FieldIssue, candidates: tuple[Account, ...]
) -> None:
    result = collect(
        CollectionInput(account_reference=reference),
        TransferOperationData(PESOS.id),
    )

    assert transfer(result).source_account_id is None
    assert result.issues == {PendingField.SOURCE_ACCOUNT_ID: issue}
    assert result.account_candidates == candidates


def test_account_status_does_not_take_part_in_resolution() -> None:
    repositories = FakeRepositories(accounts=Records([INACTIVE_PESOS]))

    result = collect(CollectionInput(), repositories=repositories)

    assert transfer(result).source_account_id == INACTIVE_PESOS.id


def test_stated_currency_resolves_the_account_in_that_currency() -> None:
    result = collect(CollectionInput(amount=Decimal("100"), currency=Currency.USD))

    assert transfer(result) == TransferOperationData(DOLLARS.id, None, usd("100"))


def test_stated_currency_without_a_unique_account_leaves_it_unresolved() -> None:
    repositories = FakeRepositories(
        accounts=Records([PESOS, account("Cuenta sueldo", Currency.ARS)])
    )

    result = collect(
        CollectionInput(amount=Decimal("100"), currency=Currency.ARS),
        repositories=repositories,
    )

    assert transfer(result) == TransferOperationData(None, None, ars("100"))
    assert result.issues == {PendingField.SOURCE_ACCOUNT_ID: FieldIssue.AMBIGUOUS}


def test_kept_amount_currency_determines_the_only_matching_account() -> None:
    result = collect(CollectionInput(), TransferOperationData(None, LAURA.id, usd("5")))

    assert transfer(result).source_account_id == DOLLARS.id


# Amount and currency.


def test_amount_without_determinable_currency_stays_unresolved() -> None:
    result = collect(CollectionInput(amount=Decimal("25000")))

    assert transfer(result) == TransferOperationData(unresolved_amount=Decimal("25000"))
    assert PendingField.AMOUNT in result.operation.missing_fields


def test_amount_takes_the_currency_of_the_resolved_account() -> None:
    result = collect(
        CollectionInput(amount=Decimal("25000")), TransferOperationData(DOLLARS.id)
    )

    assert transfer(result).amount == usd("25000")


def test_stated_currency_converts_the_unresolved_amount() -> None:
    result = collect(
        CollectionInput(currency=Currency.ARS),
        TransferOperationData(unresolved_amount=Decimal("25000")),
    )

    assert transfer(result) == TransferOperationData(PESOS.id, None, ars("25000"))


def test_stated_currency_corrects_the_resolved_amount_and_account() -> None:
    result = collect(
        CollectionInput(currency=Currency.USD),
        TransferOperationData(PESOS.id, LAURA.id, ars("100")),
    )

    assert transfer(result) == TransferOperationData(DOLLARS.id, LAURA.id, usd("100"))


def test_selected_account_converts_the_unresolved_amount() -> None:
    result = collect(
        CollectionInput(account_reference="la cuenta en dólares"),
        TransferOperationData(unresolved_amount=Decimal("25000")),
    )

    assert transfer(result) == TransferOperationData(DOLLARS.id, None, usd("25000"))
    assert result.amount_conflict is None


def test_selected_account_in_another_currency_clears_the_resolved_amount() -> None:
    result = collect(
        CollectionInput(account_reference="la cuenta en dólares"),
        TransferOperationData(PESOS.id, LAURA.id, ars("25000")),
    )

    assert transfer(result) == TransferOperationData(DOLLARS.id, LAURA.id)
    assert result.operation.missing_fields == (PendingField.AMOUNT,)
    assert result.amount_conflict == AmountCurrencyConflict(ars("25000"), Currency.USD)


def test_cleared_conflicting_amount_does_not_return_on_reselection() -> None:
    result = collect(
        CollectionInput(account_reference="la cuenta en dólares"),
        TransferOperationData(DOLLARS.id, LAURA.id),
    )

    assert transfer(result) == TransferOperationData(DOLLARS.id, LAURA.id)
    assert result.amount_conflict is None


def test_selected_account_with_a_new_amount_is_not_a_conflict() -> None:
    result = collect(
        CollectionInput(amount=Decimal("300"), account_reference="en dólares"),
        TransferOperationData(PESOS.id, LAURA.id, ars("25000")),
    )

    assert transfer(result) == TransferOperationData(DOLLARS.id, LAURA.id, usd("300"))
    assert result.amount_conflict is None


def test_account_in_another_currency_than_stated_is_not_resolved() -> None:
    result = collect(
        CollectionInput(
            amount=Decimal("100"),
            currency=Currency.ARS,
            account_reference="la cuenta en dólares",
        ),
        TransferOperationData(DOLLARS.id),
    )

    assert transfer(result) == TransferOperationData(None, None, ars("100"))
    assert result.issues == {PendingField.SOURCE_ACCOUNT_ID: FieldIssue.NOT_FOUND}


@pytest.mark.parametrize(
    ("stated", "issue"),
    [
        (CollectionInput(invalid_fields=frozenset({"amount"})), FieldIssue.INVALID),
        (
            CollectionInput(unsupported_fields=frozenset({"amount"})),
            FieldIssue.UNSUPPORTED,
        ),
        (
            CollectionInput(
                amount=Decimal("100"), unsupported_fields=frozenset({"currency"})
            ),
            FieldIssue.UNSUPPORTED,
        ),
        (CollectionInput(amount=Decimal("1E+16")), FieldIssue.INVALID),
    ],
    ids=["invalid", "unsupported", "unsupported_currency", "out_of_range"],
)
@pytest.mark.parametrize(
    "data",
    [
        TransferOperationData(PESOS.id, LAURA.id, ars("100")),
        TransferOperationData(None, LAURA.id, unresolved_amount=Decimal("100")),
    ],
    ids=["resolved", "unresolved"],
)
def test_unusable_amount_clears_the_previous_amount(
    stated: CollectionInput, issue: FieldIssue, data: TransferOperationData
) -> None:
    result = collect(stated, data)

    assert transfer(result).amount is None
    assert transfer(result).unresolved_amount is None
    assert transfer(result).beneficiary_id == LAURA.id
    assert result.issues == {PendingField.AMOUNT: issue}


# Card operations.


@pytest.mark.parametrize(
    ("operation_type", "data_type"),
    [
        (PendingOperationType.FREEZE_CARD, FreezeCardOperationData),
        (PendingOperationType.UNFREEZE_CARD, UnfreezeCardOperationData),
    ],
)
def test_card_reference_resolves_a_unique_card(
    operation_type: PendingOperationType,
    data_type: type[FreezeCardOperationData | UnfreezeCardOperationData],
) -> None:
    result = collect(
        CollectionInput(card_reference="la de débito"), operation_type=operation_type
    )

    assert result == CollectingDataResult(
        PendingOperation(operation_type, data_type(VISA_DEBIT.id))
    )


def test_ambiguous_card_correction_clears_the_card() -> None:
    result = collect(
        CollectionInput(card_reference="la Visa"),
        FreezeCardOperationData(MASTERCARD.id),
        operation_type=PendingOperationType.FREEZE_CARD,
    )

    assert result.operation.data == FreezeCardOperationData()
    assert result.issues == {PendingField.CARD_ID: FieldIssue.AMBIGUOUS}
    assert result.card_candidates == (VISA_DEBIT, VISA_CREDIT)


def test_card_operation_without_reference_keeps_the_card() -> None:
    data = UnfreezeCardOperationData(VISA_CREDIT.id)

    result = collect(
        CollectionInput(), data, operation_type=PendingOperationType.UNFREEZE_CARD
    )

    assert result.operation.data == data


def test_operation_data_must_match_the_operation_type() -> None:
    with pytest.raises(ValueError, match="requires"):
        collect(CollectionInput(), FreezeCardOperationData())
