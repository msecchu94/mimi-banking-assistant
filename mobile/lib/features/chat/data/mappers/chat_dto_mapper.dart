import '../../../../core/network/network_exception.dart';
import '../../../../core/network/wire_enum.dart';
import '../../domain/models/chat_reply.dart';
import '../../domain/models/chat_ui.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/money.dart';
import '../dtos/chat_response_dto.dart';

// Explicit DTO → Domain mapping. A value outside the contract (unknown enum
// value, malformed amount or date, timestamp without timezone) is an
// InvalidResponseException.

Conversation conversationFromDto(ConversationResponseDto dto) => _contractValue(
  () => Conversation(
    id: dto.conversationId,
    state: _enum(ConversationState.values, dto.conversationState),
  ),
);

ChatReply chatReplyFromDto(ChatResponseDto dto) => _contractValue(
  () => ChatReply(
    conversationId: dto.conversationId,
    message: dto.message,
    intent: _enum(ChatIntent.values, dto.intent),
    conversationState: _enum(ConversationState.values, dto.conversationState),
    ui: _ui(dto.ui),
  ),
);

T _contractValue<T>(T Function() map) {
  try {
    return map();
  } on FormatException catch (cause) {
    throw InvalidResponseException(cause: cause);
  }
}

ChatUi _ui(UiResponseDto dto) => switch (dto) {
  TextUiDto() => const ChatUi.text(),
  CardListUiDto(:final data) => ChatUi.cardList(
    cards: data.cards.map(_card).toList(),
  ),
  CardSelectorUiDto(:final data) => ChatUi.cardSelector(
    cards: data.cards.map(_card).toList(),
  ),
  BeneficiaryListUiDto(:final data) => ChatUi.beneficiaryList(
    beneficiaries: data.beneficiaries.map(_beneficiary).toList(),
  ),
  ConfirmationUiDto(:final data) => ChatUi.confirmation(
    operationId: data.operationId,
    title: data.title,
    summary: _summary(data.summary),
    actions: data.actions.map(_action).toList(),
  ),
  ExpenseSummaryUiDto(:final data) => ChatUi.expenseSummary(
    period: _period(data.period),
    currencies: data.currencies.map(_currencyExpenses).toList(),
  ),
  ExpenseComparisonUiDto(:final data) => ChatUi.expenseComparison(
    currentPeriod: _period(data.currentPeriod),
    previousPeriod: _period(data.previousPeriod),
    currencies: data.currencies.map(_comparison).toList(),
  ),
  TransactionListUiDto(:final data) => ChatUi.transactionList(
    transactions: data.transactions.map(_transaction).toList(),
  ),
  TransferSummaryUiDto(:final data) => ChatUi.transferSummary(
    transferId: data.transferId,
    beneficiary: data.beneficiary,
    amount: _money(data.amount),
    status: _enum(TransferStatus.values, data.status),
    executedAt: _aware(data.executedAt),
  ),
};

Money _money(MoneyDto dto) =>
    Money(amount: dto.amount, currency: _enum(Currency.values, dto.currency));

BankCard _card(CardDto dto) => BankCard(
  id: dto.id,
  brand: _enum(CardBrand.values, dto.brand),
  type: _enum(CardType.values, dto.type),
  lastFour: dto.lastFour,
  status: _enum(CardStatus.values, dto.status),
);

Beneficiary _beneficiary(BeneficiaryDto dto) => Beneficiary(
  id: dto.id,
  name: dto.name,
  accountReference: dto.accountReference,
  bankName: dto.bankName,
);

Transaction _transaction(TransactionDto dto) => Transaction(
  id: dto.id,
  description: dto.description,
  amount: _money(dto.amount),
  type: _enum(TransactionType.values, dto.type),
  category: _enum(TransactionCategory.values, dto.category),
  occurredAt: _aware(dto.occurredAt),
);

ExpensePeriod _period(ExpensePeriodDto dto) =>
    ExpensePeriod(from: _date(dto.from), to: _date(dto.to));

CurrencyExpenses _currencyExpenses(CurrencyExpensesDto dto) => CurrencyExpenses(
  total: _money(dto.total),
  categories: [
    for (final category in dto.categories)
      CategoryExpense(
        category: _enum(TransactionCategory.values, category.category),
        amount: _money(category.amount),
      ),
  ],
);

CurrencyComparison _comparison(CurrencyComparisonDto dto) => CurrencyComparison(
  currentTotal: _money(dto.currentTotal),
  previousTotal: _money(dto.previousTotal),
  difference: _money(dto.difference),
  change: _enum(ExpenseChange.values, dto.change),
);

ConfirmationSummary _summary(ConfirmationSummaryDto dto) => switch (dto) {
  TransferConfirmationSummaryDto(:final amount, :final beneficiary) =>
    ConfirmationSummary.transfer(
      amount: _money(amount),
      beneficiary: beneficiary,
    ),
  CardConfirmationSummaryDto(:final card) => ConfirmationSummary.card(
    card: _card(card),
  ),
};

ConfirmationAction _action(ConfirmationActionDto dto) => ConfirmationAction(
  type: _enum(ConfirmationActionType.values, dto.type),
  label: dto.label,
);

T _enum<T extends Enum>(List<T> values, String wire) =>
    decodeWireEnum(values, wire) ??
    (throw FormatException('Unknown ${T.toString()} value', wire));

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// A contract date (`YYYY-MM-DD`) as UTC midnight.
DateTime _date(String wire) {
  final match = _datePattern.firstMatch(wire);
  if (match == null) throw FormatException('Expected YYYY-MM-DD', wire);
  final [year, month, day] = [
    for (var group = 1; group <= 3; group++) int.parse(match[group]!),
  ];
  final date = DateTime.utc(year, month, day);
  if (date.month != month || date.day != day) {
    throw FormatException('Invalid date', wire);
  }
  return date;
}

/// The contract's timestamps carry a timezone; parsed, they are UTC.
DateTime _aware(DateTime timestamp) => timestamp.isUtc
    ? timestamp
    : throw FormatException('Expected a timestamp with timezone', '$timestamp');
