import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_response_dto.freezed.dart';
part 'chat_response_dto.g.dart';

// Wire models of the Chat API responses. Contract enum values stay strings
// here and are decoded by the domain mapper.

/// `POST /conversations` response.
@freezed
abstract class ConversationResponseDto with _$ConversationResponseDto {
  const factory ConversationResponseDto({
    required String conversationId,
    required String conversationState,
    required ResponseMetadataDto metadata,
  }) = _ConversationResponseDto;

  factory ConversationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseDtoFromJson(json);
}

/// `POST /chat` response.
@freezed
abstract class ChatResponseDto with _$ChatResponseDto {
  const factory ChatResponseDto({
    required String conversationId,
    required String message,
    required String intent,
    required String conversationState,
    required UiResponseDto ui,
    required ResponseMetadataDto metadata,
  }) = _ChatResponseDto;

  factory ChatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseDtoFromJson(json);
}

@freezed
abstract class ResponseMetadataDto with _$ResponseMetadataDto {
  const factory ResponseMetadataDto({
    required String requestId,
    required DateTime timestamp,
  }) = _ResponseMetadataDto;

  factory ResponseMetadataDto.fromJson(Map<String, dynamic> json) =>
      _$ResponseMetadataDtoFromJson(json);
}

/// `ui`, discriminated by `type`.
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.screamingSnake)
sealed class UiResponseDto with _$UiResponseDto {
  /// `TEXT` carries an empty `data` object.
  const factory UiResponseDto.text() = TextUiDto;

  const factory UiResponseDto.cardList({required CardsDataDto data}) =
      CardListUiDto;

  const factory UiResponseDto.cardSelector({required CardsDataDto data}) =
      CardSelectorUiDto;

  const factory UiResponseDto.beneficiaryList({
    required BeneficiaryListDataDto data,
  }) = BeneficiaryListUiDto;

  const factory UiResponseDto.confirmation({
    required ConfirmationDataDto data,
  }) = ConfirmationUiDto;

  const factory UiResponseDto.expenseSummary({
    required ExpenseSummaryDataDto data,
  }) = ExpenseSummaryUiDto;

  const factory UiResponseDto.expenseComparison({
    required ExpenseComparisonDataDto data,
  }) = ExpenseComparisonUiDto;

  const factory UiResponseDto.transactionList({
    required TransactionListDataDto data,
  }) = TransactionListUiDto;

  const factory UiResponseDto.transferSummary({
    required TransferSummaryDataDto data,
  }) = TransferSummaryUiDto;

  factory UiResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UiResponseDtoFromJson(json);
}

/// `data` of `CARD_LIST` and `CARD_SELECTOR`.
@freezed
abstract class CardsDataDto with _$CardsDataDto {
  const factory CardsDataDto({required List<CardDto> cards}) = _CardsDataDto;

  factory CardsDataDto.fromJson(Map<String, dynamic> json) =>
      _$CardsDataDtoFromJson(json);
}

@freezed
abstract class BeneficiaryListDataDto with _$BeneficiaryListDataDto {
  const factory BeneficiaryListDataDto({
    required List<BeneficiaryDto> beneficiaries,
  }) = _BeneficiaryListDataDto;

  factory BeneficiaryListDataDto.fromJson(Map<String, dynamic> json) =>
      _$BeneficiaryListDataDtoFromJson(json);
}

@freezed
abstract class ConfirmationDataDto with _$ConfirmationDataDto {
  const factory ConfirmationDataDto({
    required String operationId,
    required String title,
    required ConfirmationSummaryDto summary,
    required List<ConfirmationActionDto> actions,
  }) = _ConfirmationDataDto;

  factory ConfirmationDataDto.fromJson(Map<String, dynamic> json) =>
      _$ConfirmationDataDtoFromJson(json);
}

@freezed
abstract class ExpenseSummaryDataDto with _$ExpenseSummaryDataDto {
  const factory ExpenseSummaryDataDto({
    required ExpensePeriodDto period,
    required List<CurrencyExpensesDto> currencies,
  }) = _ExpenseSummaryDataDto;

  factory ExpenseSummaryDataDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSummaryDataDtoFromJson(json);
}

@freezed
abstract class ExpenseComparisonDataDto with _$ExpenseComparisonDataDto {
  const factory ExpenseComparisonDataDto({
    required ExpensePeriodDto currentPeriod,
    required ExpensePeriodDto previousPeriod,
    required List<CurrencyComparisonDto> currencies,
  }) = _ExpenseComparisonDataDto;

  factory ExpenseComparisonDataDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseComparisonDataDtoFromJson(json);
}

@freezed
abstract class TransactionListDataDto with _$TransactionListDataDto {
  const factory TransactionListDataDto({
    required List<TransactionDto> transactions,
  }) = _TransactionListDataDto;

  factory TransactionListDataDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionListDataDtoFromJson(json);
}

@freezed
abstract class TransferSummaryDataDto with _$TransferSummaryDataDto {
  const factory TransferSummaryDataDto({
    required String transferId,
    required String beneficiary,
    required MoneyDto amount,
    required String status,
    required DateTime executedAt,
  }) = _TransferSummaryDataDto;

  factory TransferSummaryDataDto.fromJson(Map<String, dynamic> json) =>
      _$TransferSummaryDataDtoFromJson(json);
}

@freezed
abstract class MoneyDto with _$MoneyDto {
  const factory MoneyDto({required String amount, required String currency}) =
      _MoneyDto;

  factory MoneyDto.fromJson(Map<String, dynamic> json) =>
      _$MoneyDtoFromJson(json);
}

@freezed
abstract class CardDto with _$CardDto {
  const factory CardDto({
    required String id,
    required String brand,
    required String type,
    required String lastFour,
    required String status,
  }) = _CardDto;

  factory CardDto.fromJson(Map<String, dynamic> json) =>
      _$CardDtoFromJson(json);
}

@freezed
abstract class BeneficiaryDto with _$BeneficiaryDto {
  const factory BeneficiaryDto({
    required String id,
    required String name,
    required String accountReference,
    required String? bankName,
  }) = _BeneficiaryDto;

  factory BeneficiaryDto.fromJson(Map<String, dynamic> json) =>
      _$BeneficiaryDtoFromJson(json);
}

@freezed
abstract class TransactionDto with _$TransactionDto {
  const factory TransactionDto({
    required String id,
    required String description,
    required MoneyDto amount,
    required String type,
    required String category,
    required DateTime occurredAt,
  }) = _TransactionDto;

  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
}

/// Dates as `YYYY-MM-DD`; `to` is inclusive.
@freezed
abstract class ExpensePeriodDto with _$ExpensePeriodDto {
  const factory ExpensePeriodDto({required String from, required String to}) =
      _ExpensePeriodDto;

  factory ExpensePeriodDto.fromJson(Map<String, dynamic> json) =>
      _$ExpensePeriodDtoFromJson(json);
}

@freezed
abstract class CurrencyExpensesDto with _$CurrencyExpensesDto {
  const factory CurrencyExpensesDto({
    required MoneyDto total,
    required List<CategoryExpenseDto> categories,
  }) = _CurrencyExpensesDto;

  factory CurrencyExpensesDto.fromJson(Map<String, dynamic> json) =>
      _$CurrencyExpensesDtoFromJson(json);
}

@freezed
abstract class CategoryExpenseDto with _$CategoryExpenseDto {
  const factory CategoryExpenseDto({
    required String category,
    required MoneyDto amount,
  }) = _CategoryExpenseDto;

  factory CategoryExpenseDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryExpenseDtoFromJson(json);
}

@freezed
abstract class CurrencyComparisonDto with _$CurrencyComparisonDto {
  const factory CurrencyComparisonDto({
    required MoneyDto currentTotal,
    required MoneyDto previousTotal,
    required MoneyDto difference,
    required String change,
  }) = _CurrencyComparisonDto;

  factory CurrencyComparisonDto.fromJson(Map<String, dynamic> json) =>
      _$CurrencyComparisonDtoFromJson(json);
}

/// `summary` of `CONFIRMATION`, discriminated by `type`.
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.screamingSnake)
sealed class ConfirmationSummaryDto with _$ConfirmationSummaryDto {
  const factory ConfirmationSummaryDto.transfer({
    required MoneyDto amount,
    required String beneficiary,
  }) = TransferConfirmationSummaryDto;

  const factory ConfirmationSummaryDto.card({required CardDto card}) =
      CardConfirmationSummaryDto;

  factory ConfirmationSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ConfirmationSummaryDtoFromJson(json);
}

@freezed
abstract class ConfirmationActionDto with _$ConfirmationActionDto {
  const factory ConfirmationActionDto({
    required String type,
    required String label,
  }) = _ConfirmationActionDto;

  factory ConfirmationActionDto.fromJson(Map<String, dynamic> json) =>
      _$ConfirmationActionDtoFromJson(json);
}
