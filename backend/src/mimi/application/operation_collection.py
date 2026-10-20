"""Collect the data of a pending state-changing operation.

Stated references are resolved deterministically against the customer's own
records; only a unique match becomes operation data, as its identifier. A
stated value that is ambiguous, not found, invalid or unsupported never
becomes operation data: the field becomes missing, even when it replaces a
value resolved earlier, while independently resolved values of the same turn
are kept. Unstated fields keep their value.

Resolution ignores account and card status; those rules belong to
pre-validation.

A transfer amount becomes ``Money`` only once its currency is determined:
stated by the user, or the currency of the resolved source account.
Otherwise it is kept as ``unresolved_amount``. An amount already resolved in
one currency is never converted to the currency of a source account the user
selects later: it is cleared instead.
"""

import re
import unicodedata
from collections.abc import Sequence
from decimal import Decimal
from uuid import UUID

from mimi.application.amounts import is_valid_transfer_amount
from mimi.application.conversation_results import (
    AmountCurrencyConflict,
    CollectingDataResult,
    FieldIssue,
)
from mimi.application.interpretation import CollectionInput
from mimi.application.pending_operations import (
    FreezeCardOperationData,
    PendingField,
    PendingOperation,
    PendingOperationData,
    TransferOperationData,
    UnfreezeCardOperationData,
)
from mimi.application.repositories import Repositories
from mimi.domain.entities import Account, Beneficiary, Card, Money
from mimi.domain.enums import CardBrand, CardType, Currency, PendingOperationType

_TOKEN = re.compile(r"[a-z0-9]+")

# Words that only introduce a reference, as in "a Carlos" or "mi cuenta".
_BENEFICIARY_FILLER = frozenset({"a", "to", "para", "mi", "my"})
_ACCOUNT_FILLER = frozenset(
    {
        "a",
        "account",
        "cuenta",
        "de",
        "del",
        "desde",
        "el",
        "en",
        "from",
        "in",
        "la",
        "mi",
        "my",
        "of",
        "the",
    }
)

_CURRENCY_WORDS = {
    "ars": Currency.ARS,
    "peso": Currency.ARS,
    "pesos": Currency.ARS,
    "usd": Currency.USD,
    "dolar": Currency.USD,
    "dolares": Currency.USD,
    "dollar": Currency.USD,
    "dollars": Currency.USD,
}
_CARD_BRANDS = {
    "visa": CardBrand.VISA,
    "master": CardBrand.MASTERCARD,
    "mastercard": CardBrand.MASTERCARD,
}
_CARD_TYPES = {
    "debit": CardType.DEBIT,
    "debito": CardType.DEBIT,
    "credit": CardType.CREDIT,
    "credito": CardType.CREDIT,
}


def collect_operation(
    repositories: Repositories,
    customer_id: UUID,
    operation_type: PendingOperationType,
    data: PendingOperationData | None,
    stated: CollectionInput,
) -> CollectingDataResult:
    """Merge ``stated`` into ``data``, the operation's current data or
    ``None`` when it starts.

    The result may be complete; whether it may wait for confirmation is
    decided by pre-validation.
    """
    match operation_type:
        case PendingOperationType.TRANSFER:
            transfer = TransferOperationData() if data is None else data
            if not isinstance(transfer, TransferOperationData):
                raise ValueError(f"{operation_type} requires transfer data")
            return _collect_transfer(repositories, customer_id, transfer, stated)
        case PendingOperationType.FREEZE_CARD | PendingOperationType.UNFREEZE_CARD:
            if data is not None and not isinstance(
                data, FreezeCardOperationData | UnfreezeCardOperationData
            ):
                raise ValueError(f"{operation_type} requires card data")
            card_id = None if data is None else data.card_id
            return _collect_card(
                repositories, customer_id, operation_type, card_id, stated
            )


def match_beneficiaries(
    reference: str, beneficiaries: Sequence[Beneficiary]
) -> tuple[Beneficiary, ...]:
    """Beneficiaries whose name contains every word of ``reference``, ignoring
    case and accents; an exact full-name match excludes partial ones."""
    wanted = [word for word in _words(reference) if word not in _BENEFICIARY_FILLER]
    if not wanted:
        return ()
    named = [(beneficiary, _words(beneficiary.name)) for beneficiary in beneficiaries]
    exact = tuple(beneficiary for beneficiary, name in named if name == wanted)
    if exact:
        return exact
    return tuple(beneficiary for beneficiary, name in named if set(wanted) <= set(name))


def match_cards(reference: str, cards: Sequence[Card]) -> tuple[Card, ...]:
    """Cards matching every brand, type and trailing digits in ``reference``.

    Other words do not discriminate, so a generic reference such as "mi
    tarjeta" matches every card.
    """
    words = _words(reference)
    brands = {_CARD_BRANDS[word] for word in words if word in _CARD_BRANDS}
    types = {_CARD_TYPES[word] for word in words if word in _CARD_TYPES}
    digits = [word for word in words if word.isdigit()]
    return tuple(
        card
        for card in cards
        if all(card.brand is brand for brand in brands)
        and all(card.type is card_type for card_type in types)
        and all(card.last_four.endswith(digit) for digit in digits)
    )


def match_accounts(
    reference: str | None, accounts: Sequence[Account], currency: Currency | None
) -> tuple[Account, ...]:
    """Accounts in ``currency``, when given, matching ``reference``, when
    given: every currency it names and every other word of the account name."""
    candidates = [
        account
        for account in accounts
        if currency is None or account.balance.currency is currency
    ]
    if reference is None:
        return tuple(candidates)
    words = _words(reference)
    currencies = {_CURRENCY_WORDS[word] for word in words if word in _CURRENCY_WORDS}
    wanted = {
        word
        for word in words
        if word not in _ACCOUNT_FILLER and word not in _CURRENCY_WORDS
    }
    return tuple(
        account
        for account in candidates
        if all(account.balance.currency is named for named in currencies)
        and wanted <= set(_words(account.name))
    )


def _collect_card(
    repositories: Repositories,
    customer_id: UUID,
    operation_type: PendingOperationType,
    card_id: UUID | None,
    stated: CollectionInput,
) -> CollectingDataResult:
    issues: dict[PendingField, FieldIssue] = {}
    candidates: tuple[Card, ...] = ()
    if "card_reference" in stated.invalid_fields:
        card_id = None
        issues[PendingField.CARD_ID] = FieldIssue.INVALID
    elif stated.card_reference is not None:
        cards = repositories.cards.list_by_customer(customer_id)
        card, issue, candidates = _resolve(match_cards(stated.card_reference, cards))
        card_id = None if card is None else card.id
        if issue is not None:
            issues[PendingField.CARD_ID] = issue
    data = (
        FreezeCardOperationData(card_id)
        if operation_type is PendingOperationType.FREEZE_CARD
        else UnfreezeCardOperationData(card_id)
    )
    return CollectingDataResult(
        PendingOperation(operation_type, data), issues, card_candidates=candidates
    )


def _collect_transfer(
    repositories: Repositories,
    customer_id: UUID,
    data: TransferOperationData,
    stated: CollectionInput,
) -> CollectingDataResult:
    issues: dict[PendingField, FieldIssue] = {}

    beneficiary_id = data.beneficiary_id
    beneficiary_candidates: tuple[Beneficiary, ...] = ()
    if "beneficiary_reference" in stated.invalid_fields:
        beneficiary_id = None
        issues[PendingField.BENEFICIARY_ID] = FieldIssue.INVALID
    elif stated.beneficiary_reference is not None:
        beneficiaries = repositories.beneficiaries.list_by_customer(customer_id)
        beneficiary, issue, beneficiary_candidates = _resolve(
            match_beneficiaries(stated.beneficiary_reference, beneficiaries)
        )
        beneficiary_id = None if beneficiary is None else beneficiary.id
        if issue is not None:
            issues[PendingField.BENEFICIARY_ID] = issue

    # An amount stated in an unusable currency is not a usable amount either.
    amount_issue = _rejection("amount", stated) or _rejection("currency", stated)
    stated_amount = stated.amount
    if stated_amount is not None and not is_valid_transfer_amount(stated_amount):
        amount_issue = FieldIssue.INVALID
    stated_currency = stated.currency

    accounts = repositories.accounts.list_by_customer(customer_id)
    currencies = {account.id: account.balance.currency for account in accounts}
    source_id = data.source_account_id
    account_candidates: tuple[Account, ...] = ()
    selected = False
    if "account_reference" in stated.invalid_fields:
        source_id = None
        issues[PendingField.SOURCE_ACCOUNT_ID] = FieldIssue.INVALID
    elif stated.account_reference is not None:
        account, issue, account_candidates = _resolve(
            match_accounts(stated.account_reference, accounts, stated_currency)
        )
        source_id = None if account is None else account.id
        selected = account is not None
        if issue is not None:
            issues[PendingField.SOURCE_ACCOUNT_ID] = issue
    elif stated_currency is not None and (
        source_id is None or currencies.get(source_id) is not stated_currency
    ):
        account, issue, account_candidates = _resolve(
            match_accounts(None, accounts, stated_currency)
        )
        source_id = None if account is None else account.id
        if issue is not None:
            issues[PendingField.SOURCE_ACCOUNT_ID] = issue
    elif source_id is None:
        # Determined only by authoritative data: the customer's only account,
        # or only account in the currency of the amount being kept.
        kept_currency = (
            data.amount.currency
            if data.amount is not None
            and amount_issue is None
            and stated_amount is None
            else None
        )
        matches = match_accounts(None, accounts, kept_currency)
        source_id = matches[0].id if len(matches) == 1 else None
    source_currency = None if source_id is None else currencies.get(source_id)
    newly_resolved = source_id is not None and source_id != data.source_account_id

    amount = data.amount
    unresolved_amount = data.unresolved_amount
    amount_conflict = None
    if amount_issue is not None:
        amount = unresolved_amount = None
        issues[PendingField.AMOUNT] = amount_issue
    elif stated_amount is not None:
        amount, unresolved_amount = _amount(
            stated_amount, stated_currency or source_currency
        )
    elif stated_currency is not None:
        value = amount.amount if amount is not None else unresolved_amount
        if value is not None:
            amount, unresolved_amount = _amount(value, stated_currency)
    elif (
        amount is not None
        and selected
        and source_currency is not None
        and source_currency is not amount.currency
    ):
        amount_conflict = AmountCurrencyConflict(amount, source_currency)
        amount = None
    elif unresolved_amount is not None and newly_resolved:
        amount, unresolved_amount = _amount(unresolved_amount, source_currency)

    operation = PendingOperation(
        PendingOperationType.TRANSFER,
        TransferOperationData(source_id, beneficiary_id, amount, unresolved_amount),
    )
    return CollectingDataResult(
        operation,
        issues,
        beneficiary_candidates=beneficiary_candidates,
        account_candidates=account_candidates,
        amount_conflict=amount_conflict,
    )


def _amount(
    value: Decimal, currency: Currency | None
) -> tuple[Money | None, Decimal | None]:
    """The amount as ``(amount, unresolved_amount)``."""
    if currency is None:
        return None, value
    return Money(value, currency), None


def _rejection(name: str, stated: CollectionInput) -> FieldIssue | None:
    if name in stated.invalid_fields:
        return FieldIssue.INVALID
    if name in stated.unsupported_fields:
        return FieldIssue.UNSUPPORTED
    return None


def _resolve[T](
    matches: tuple[T, ...],
) -> tuple[T | None, FieldIssue | None, tuple[T, ...]]:
    """The unique match, or why there is none and, when ambiguous, the
    candidates."""
    if len(matches) == 1:
        return matches[0], None, ()
    if not matches:
        return None, FieldIssue.NOT_FOUND, ()
    return None, FieldIssue.AMBIGUOUS, matches


def _words(text: str) -> list[str]:
    """Lowercase words of ``text`` without accents."""
    decomposed = unicodedata.normalize("NFKD", text.casefold())
    plain = "".join(char for char in decomposed if not unicodedata.combining(char))
    return _TOKEN.findall(plain)
