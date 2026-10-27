"""Deterministic presentation of a conversation turn as a Chat API response.

Text and UI data are derived only from the turn's result and fixed labels:
nothing is calculated, looked up or interpreted here.
"""

from datetime import time, timedelta
from decimal import Decimal
from typing import assert_never
from zoneinfo import ZoneInfo

from mimi.api.chat_models import (
    BeneficiaryItem,
    BeneficiaryListUi,
    BeneficiaryListUiData,
    CardConfirmationSummary,
    CardItem,
    CardListUi,
    CardListUiData,
    CardSelectorUi,
    CardSelectorUiData,
    CategoryExpense,
    ChatResponse,
    ConfirmationAction,
    ConfirmationActionType,
    ConfirmationUi,
    ConfirmationUiData,
    CurrencyComparison,
    CurrencyExpenses,
    ExpenseChange,
    ExpenseComparisonUi,
    ExpenseComparisonUiData,
    ExpensePeriod,
    ExpenseSummaryUi,
    ExpenseSummaryUiData,
    IntentType,
    Money,
    ResponseMetadata,
    TextUi,
    TransactionItem,
    TransactionListUi,
    TransactionListUiData,
    TransferConfirmationSummary,
    TransferSummaryUi,
    TransferSummaryUiData,
    UiResponse,
)
from mimi.application.conversation_engine import Turn
from mimi.application.conversation_results import (
    AwaitingConfirmationResult,
    BalancesResult,
    BeneficiariesResult,
    CardsResult,
    CollectingDataResult,
    ExpenseAnalysisResult,
    ExpenseComparisonResult,
    FieldIssue,
    IncompleteQueryResult,
    NoPendingOperationResult,
    OperationCancelledResult,
    OperationCompletedResult,
    OperationFailedResult,
    PendingOperationConflictResult,
    PreValidationFailedResult,
    TransactionsResult,
    TurnResult,
    UnhandledIntentResult,
)
from mimi.application.errors import PendingOperationConflictError
from mimi.application.interactions import Confirm
from mimi.application.interpretation import Intent
from mimi.application.pending_operations import (
    PendingField,
    PendingOperation,
    TransferOperationData,
)
from mimi.application.use_cases.analyze_expenses import ExpenseAnalysis, Period
from mimi.application.use_cases.compare_expenses import ExpenseComparison
from mimi.domain import entities
from mimi.domain.enums import CardBrand, CardStatus, CardType, PendingOperationType

_CENT = Decimal("0.01")

_CARD_BRANDS = {CardBrand.VISA: "Visa", CardBrand.MASTERCARD: "Mastercard"}
_CARD_TYPES = {CardType.DEBIT: "débito", CardType.CREDIT: "crédito"}
_CARD_VERBS = {
    PendingOperationType.FREEZE_CARD: "congelar",
    PendingOperationType.UNFREEZE_CARD: "descongelar",
}
_CARD_TITLES = {
    PendingOperationType.FREEZE_CARD: "Congelar tarjeta",
    PendingOperationType.UNFREEZE_CARD: "Descongelar tarjeta",
}
_CARD_STATUSES = {CardStatus.FROZEN: "congelada", CardStatus.ACTIVE: "activa"}
_OPERATIONS = {
    PendingOperationType.TRANSFER: "la transferencia",
    PendingOperationType.FREEZE_CARD: "el congelamiento de la tarjeta",
    PendingOperationType.UNFREEZE_CARD: "el descongelamiento de la tarjeta",
}
_QUERY_FIELDS = {
    "period": "el período",
    "comparison_period": "el período a comparar",
    "category": "la categoría",
    "transaction_type": "el tipo de movimiento",
}
_UNHANDLED = {
    Intent.GENERAL_CONVERSATION: (
        "Puedo ayudarte con saldos, movimientos, gastos, tarjetas y transferencias."
    ),
    Intent.CANCEL: "Para cancelar una operación, usá la opción Cancelar.",
}
_NOT_UNDERSTOOD = "No entendí tu mensaje. ¿Podés reformularlo?"
_TRANSFER_QUESTIONS = {
    PendingField.SOURCE_ACCOUNT_ID: "¿Desde qué cuenta querés transferir?",
    PendingField.BENEFICIARY_ID: "¿A quién querés transferir?",
    PendingField.AMOUNT: "¿Cuánto querés transferir?",
}
_TRANSFER_ISSUES = {
    PendingField.SOURCE_ACCOUNT_ID: "No encontré esa cuenta.",
    PendingField.BENEFICIARY_ID: "No encontré ese destinatario.",
    PendingField.AMOUNT: "No pude usar el monto indicado.",
}
_ACTIONS = [
    ConfirmationAction(type=ConfirmationActionType.CONFIRM, label="Confirmar"),
    ConfirmationAction(type=ConfirmationActionType.CANCEL, label="Cancelar"),
]


def present_turn(
    turn: Turn, timezone: ZoneInfo, metadata: ResponseMetadata
) -> ChatResponse:
    """The response to ``turn``; periods are shown as local dates in
    ``timezone``.

    Raises the result's ``ApplicationError`` when the operation could not be
    performed, and ``PendingOperationConflictError`` when another operation
    is pending.
    """
    message, ui = _present(turn.result, timezone)
    return ChatResponse(
        conversation_id=turn.conversation_id,
        message=message,
        intent=IntentType(turn.intent.value),
        conversation_state=turn.flow_state,
        ui=ui,
        metadata=metadata,
    )


def _present(result: TurnResult, timezone: ZoneInfo) -> tuple[str, UiResponse]:
    match result:
        case BalancesResult(accounts=accounts):
            return _balances(accounts), TextUi()
        case TransactionsResult(transactions=transactions):
            return _counted(len(transactions), "movimiento", "movimientos"), (
                TransactionListUi(
                    data=TransactionListUiData(
                        transactions=[_transaction(t) for t in transactions]
                    )
                )
            )
        case ExpenseAnalysisResult(analysis=analysis):
            data = ExpenseSummaryUiData(
                period=_period(analysis.period, timezone),
                currencies=[
                    CurrencyExpenses(
                        total=_money(expenses.total),
                        categories=[
                            CategoryExpense(category=c.category, amount=_money(c.total))
                            for c in expenses.categories
                        ],
                    )
                    for expenses in analysis.currencies
                ],
            )
            return _expense_summary(analysis), ExpenseSummaryUi(data=data)
        case ExpenseComparisonResult(comparison=comparison):
            comparison_data = ExpenseComparisonUiData(
                current_period=_period(comparison.current.period, timezone),
                previous_period=_period(comparison.previous.period, timezone),
                currencies=[
                    CurrencyComparison(
                        current_total=_money(c.current_total),
                        previous_total=_money(c.previous_total),
                        difference=_money(c.difference),
                        change=ExpenseChange(c.change.value),
                    )
                    for c in comparison.currencies
                ],
            )
            return _expense_comparison(comparison), ExpenseComparisonUi(
                data=comparison_data
            )
        case CardsResult(cards=cards):
            return _counted(len(cards), "tarjeta", "tarjetas"), CardListUi(
                data=CardListUiData(cards=[_card(c) for c in cards])
            )
        case BeneficiariesResult(beneficiaries=beneficiaries):
            message = (
                "Estos son tus destinatarios guardados."
                if beneficiaries
                else "No encontré destinatarios guardados."
            )
            return message, BeneficiaryListUi(
                data=BeneficiaryListUiData(
                    beneficiaries=[_beneficiary(b) for b in beneficiaries]
                )
            )
        case IncompleteQueryResult():
            return _incomplete_query(result), TextUi()
        case UnhandledIntentResult(intent=intent):
            return _UNHANDLED.get(intent, _NOT_UNDERSTOOD), TextUi()
        case CollectingDataResult(operation=operation):
            if operation.type is PendingOperationType.TRANSFER:
                return _collecting_transfer(result), TextUi()
            return _collecting_card(result)
        case AwaitingConfirmationResult():
            return _awaiting_confirmation(result)
        case (
            PreValidationFailedResult(error=error) | OperationFailedResult(error=error)
        ):
            raise error
        case PendingOperationConflictResult():
            raise PendingOperationConflictError()
        case OperationCompletedResult():
            return _completed(result)
        case OperationCancelledResult(operation=operation):
            return (
                f"Listo, cancelé {_OPERATIONS[operation.type]}. "
                "No se realizó ningún cambio.",
                TextUi(),
            )
        case NoPendingOperationResult(interaction=interaction):
            if isinstance(interaction, Confirm):
                return "No hay ninguna operación pendiente de confirmación.", TextUi()
            return "No hay ninguna operación pendiente para cancelar.", TextUi()
        case _:
            assert_never(result)


def _money(money: entities.Money) -> Money:
    return Money(amount=money.amount, currency=money.currency)


def _money_text(money: entities.Money) -> str:
    return f"{money.amount.quantize(_CENT):f} {money.currency}"


def _period(period: Period, timezone: ZoneInfo) -> ExpensePeriod:
    """The local days of a half-open period of whole local days."""
    start = period.start.astimezone(timezone)
    end = period.end.astimezone(timezone)
    if start.time() != time.min or end.time() != time.min:
        raise ValueError("a period must span whole local days")
    return ExpensePeriod(from_=start.date(), to=end.date() - timedelta(days=1))


def _card(card: entities.Card) -> CardItem:
    return CardItem(
        id=card.id,
        brand=card.brand,
        type=card.type,
        last_four=card.last_four,
        status=card.status,
    )


def _card_text(card: entities.Card) -> str:
    return (
        f"{_CARD_BRANDS[card.brand]} de {_CARD_TYPES[card.type]} "
        f"terminada en {card.last_four}"
    )


def _beneficiary(beneficiary: entities.Beneficiary) -> BeneficiaryItem:
    return BeneficiaryItem(
        id=beneficiary.id,
        name=beneficiary.name,
        account_reference=f"****{beneficiary.account_reference[-4:]}",
        bank_name=beneficiary.bank_name,
    )


def _transaction(transaction: entities.Transaction) -> TransactionItem:
    return TransactionItem(
        id=transaction.id,
        description=transaction.description,
        amount=_money(transaction.amount),
        type=transaction.type,
        category=transaction.category,
        occurred_at=transaction.occurred_at,
    )


def _counted(count: int, singular: str, plural: str) -> str:
    if count == 0:
        return f"No encontré {plural}."
    return f"Encontré {count} {singular if count == 1 else plural}."


def _balances(accounts: tuple[entities.Account, ...]) -> str:
    if not accounts:
        return "No encontré cuentas."
    if len(accounts) == 1:
        [account] = accounts
        return f"El saldo de {account.name} es {_money_text(account.balance)}."
    balances = "; ".join(f"{a.name}: {_money_text(a.balance)}" for a in accounts)
    return f"Estos son tus saldos: {balances}."


def _joined(texts: list[str]) -> str:
    if len(texts) <= 1:
        return "".join(texts)
    return f"{', '.join(texts[:-1])} y {texts[-1]}"


def _expense_summary(analysis: ExpenseAnalysis) -> str:
    if not analysis.currencies:
        return "No hay gastos en ese período."
    totals = _joined([_money_text(c.total) for c in analysis.currencies])
    return f"Tus gastos del período suman {totals}."


def _expense_comparison(comparison: ExpenseComparison) -> str:
    if not comparison.currencies:
        return "No hay gastos en ninguno de los dos períodos."
    changes = []
    for c in comparison.currencies:
        difference = _money_text(c.difference)
        match ExpenseChange(c.change.value):
            case ExpenseChange.INCREASE:
                changes.append(f"en {c.currency} gastaste {difference} más")
            case ExpenseChange.DECREASE:
                changes.append(f"en {c.currency} gastaste {difference} menos")
            case ExpenseChange.UNCHANGED:
                changes.append(f"en {c.currency} gastaste lo mismo")
    return f"Respecto del período comparado, {_joined(changes)}."


def _incomplete_query(result: IncompleteQueryResult) -> str:
    if "context" in result.missing_fields:
        return (
            "No tengo una consulta anterior a la cual referirme. ¿Qué querés consultar?"
        )
    sentences = []
    if result.missing_fields:
        sentences.append(f"Necesito que me indiques {_fields(result.missing_fields)}.")
    if result.unsupported_fields:
        sentences.append(
            f"Todavía no puedo usar {_fields(result.unsupported_fields)} que indicaste."
        )
    if result.invalid_fields:
        sentences.append(f"No pude entender {_fields(result.invalid_fields)}.")
    return " ".join(sentences) or _NOT_UNDERSTOOD


def _fields(names: frozenset[str]) -> str:
    labels = sorted({_QUERY_FIELDS.get(name, "algunos datos") for name in names})
    return _joined(labels)


def _collecting_transfer(result: CollectingDataResult) -> str:
    sentences = []
    if result.amount_conflict is not None:
        conflict = result.amount_conflict
        sentences.append(
            f"El monto de {_money_text(conflict.previous)} no corresponde a la "
            f"moneda de la cuenta elegida ({conflict.selected_currency})."
        )
    for field, issue in result.issues.items():
        if issue is FieldIssue.AMBIGUOUS:
            continue
        sentences.append(_TRANSFER_ISSUES[field])
    if result.beneficiary_candidates:
        names = _joined([b.name for b in result.beneficiary_candidates])
        sentences.append(f"Encontré varios destinatarios: {names}.")
    if result.account_candidates:
        names = _joined([a.name for a in result.account_candidates])
        sentences.append(f"Encontré varias cuentas: {names}.")
    missing = result.operation.missing_fields
    if missing:
        sentences.append(_TRANSFER_QUESTIONS[missing[0]])
    return " ".join(sentences)


def _collecting_card(result: CollectingDataResult) -> tuple[str, UiResponse]:
    question = f"¿Qué tarjeta querés {_CARD_VERBS[result.operation.type]}?"
    if result.card_candidates:
        return question, CardSelectorUi(
            data=CardSelectorUiData(cards=[_card(c) for c in result.card_candidates])
        )
    match result.issues.get(PendingField.CARD_ID):
        case FieldIssue.NOT_FOUND:
            return f"No encontré esa tarjeta. {question}", TextUi()
        case FieldIssue.INVALID | FieldIssue.UNSUPPORTED:
            return f"No pude identificar la tarjeta. {question}", TextUi()
        case _:
            return question, TextUi()


def _awaiting_confirmation(
    result: AwaitingConfirmationResult,
) -> tuple[str, UiResponse]:
    operation = result.operation
    if operation.operation_id is None:
        raise ValueError("an operation waiting for confirmation has an id")
    match operation.data:
        case TransferOperationData(amount=entities.Money() as amount):
            if result.beneficiary is None or result.source_account is None:
                raise ValueError("a transfer confirmation has its records")
            message = (
                f"¿Confirmás la transferencia de {_money_text(amount)} a "
                f"{result.beneficiary.name} desde {result.source_account.name}?"
            )
            title = "Confirmar transferencia"
            summary: TransferConfirmationSummary | CardConfirmationSummary = (
                TransferConfirmationSummary(
                    amount=_money(amount), beneficiary=result.beneficiary.name
                )
            )
        case _:
            card = _required_card(result.card, operation)
            message = (
                f"¿Confirmás que querés {_CARD_VERBS[operation.type]} la "
                f"tarjeta {_card_text(card)}?"
            )
            title = _CARD_TITLES[operation.type]
            summary = CardConfirmationSummary(card=_card(card))
    return message, ConfirmationUi(
        data=ConfirmationUiData(
            operation_id=operation.operation_id,
            title=title,
            summary=summary,
            actions=_ACTIONS,
        )
    )


def _completed(result: OperationCompletedResult) -> tuple[str, UiResponse]:
    if result.operation.type is PendingOperationType.TRANSFER:
        transfer, beneficiary = result.transfer, result.beneficiary
        if transfer is None or beneficiary is None or transfer.executed_at is None:
            raise ValueError("a completed transfer has its records")
        return (
            f"La transferencia de {_money_text(transfer.amount)} a "
            f"{beneficiary.name} se realizó con éxito.",
            TransferSummaryUi(
                data=TransferSummaryUiData(
                    transfer_id=transfer.id,
                    beneficiary=beneficiary.name,
                    amount=_money(transfer.amount),
                    status=transfer.status,
                    executed_at=transfer.executed_at,
                )
            ),
        )
    card = _required_card(result.card, result.operation)
    return (
        f"Tu tarjeta {_card_text(card)} quedó {_CARD_STATUSES[card.status]}.",
        CardListUi(data=CardListUiData(cards=[_card(card)])),
    )


def _required_card(
    card: entities.Card | None, operation: PendingOperation
) -> entities.Card:
    if card is None or operation.type is PendingOperationType.TRANSFER:
        raise ValueError("a card operation result has its card")
    return card
