import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';

part 'chat_ui.freezed.dart';

/// The semantic UI of a reply: one variant per contract `ui.type`, each with
/// its own data. Values are supplied by the backend; the client renders them.
@freezed
sealed class ChatUi with _$ChatUi {
  const factory ChatUi.text() = TextUi;

  const factory ChatUi.cardList({required List<BankCard> cards}) = CardListUi;

  /// The user must pick one of [cards] to continue the pending operation.
  const factory ChatUi.cardSelector({required List<BankCard> cards}) =
      CardSelectorUi;

  const factory ChatUi.beneficiaryList({
    required List<Beneficiary> beneficiaries,
  }) = BeneficiaryListUi;

  /// A pre-validated operation waiting for explicit authorization under
  /// [operationId].
  const factory ChatUi.confirmation({
    required String operationId,
    required String title,
    required ConfirmationSummary summary,
    required List<ConfirmationAction> actions,
  }) = ConfirmationUi;

  /// Expenses per currency; [currencies] is empty when there were none.
  const factory ChatUi.expenseSummary({
    required ExpensePeriod period,
    required List<CurrencyExpenses> currencies,
  }) = ExpenseSummaryUi;

  const factory ChatUi.expenseComparison({
    required ExpensePeriod currentPeriod,
    required ExpensePeriod previousPeriod,
    required List<CurrencyComparison> currencies,
  }) = ExpenseComparisonUi;

  const factory ChatUi.transactionList({
    required List<Transaction> transactions,
  }) = TransactionListUi;

  const factory ChatUi.transferSummary({
    required String transferId,
    required String beneficiary,
    required Money amount,
    required TransferStatus status,
    required DateTime executedAt,
  }) = TransferSummaryUi;
}

@freezed
abstract class BankCard with _$BankCard {
  const factory BankCard({
    required String id,
    required CardBrand brand,
    required CardType type,
    required String lastFour,
    required CardStatus status,
  }) = _BankCard;
}

enum CardBrand { visa, mastercard }

enum CardType { debit, credit }

enum CardStatus { active, frozen }

@freezed
abstract class Beneficiary with _$Beneficiary {
  const factory Beneficiary({
    required String id,
    required String name,

    /// A masked reference, e.g. `****4582`.
    required String accountReference,
    required String? bankName,
  }) = _Beneficiary;
}

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String description,
    required Money amount,

    /// The direction; never inferred from the amount's sign.
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
  }) = _Transaction;
}

enum TransactionType { debit, credit }

enum TransactionCategory {
  groceries,
  dining,
  transport,
  fuel,
  utilities,
  subscriptions,
  entertainment,
  shopping,
  transfer,
  other,
}

/// A period of whole calendar days; [from] and [to] are dates (UTC midnight)
/// and [to] is inclusive.
@freezed
abstract class ExpensePeriod with _$ExpensePeriod {
  const factory ExpensePeriod({required DateTime from, required DateTime to}) =
      _ExpensePeriod;
}

/// Expenses in one currency; currencies are never combined or converted.
@freezed
abstract class CurrencyExpenses with _$CurrencyExpenses {
  const factory CurrencyExpenses({
    required Money total,
    required List<CategoryExpense> categories,
  }) = _CurrencyExpenses;
}

@freezed
abstract class CategoryExpense with _$CategoryExpense {
  const factory CategoryExpense({
    required TransactionCategory category,
    required Money amount,
  }) = _CategoryExpense;
}

/// One currency's totals in both periods. [difference] is a non-negative
/// magnitude; [change] carries its direction.
@freezed
abstract class CurrencyComparison with _$CurrencyComparison {
  const factory CurrencyComparison({
    required Money currentTotal,
    required Money previousTotal,
    required Money difference,
    required ExpenseChange change,
  }) = _CurrencyComparison;
}

enum ExpenseChange { increase, decrease, unchanged }

/// What a confirmation authorizes, shaped by the operation type.
@freezed
sealed class ConfirmationSummary with _$ConfirmationSummary {
  const factory ConfirmationSummary.transfer({
    required Money amount,
    required String beneficiary,
  }) = TransferConfirmationSummary;

  const factory ConfirmationSummary.card({required BankCard card}) =
      CardConfirmationSummary;
}

@freezed
abstract class ConfirmationAction with _$ConfirmationAction {
  const factory ConfirmationAction({
    required ConfirmationActionType type,
    required String label,
  }) = _ConfirmationAction;
}

enum ConfirmationActionType { confirm, cancel }

enum TransferStatus { completed, failed }
