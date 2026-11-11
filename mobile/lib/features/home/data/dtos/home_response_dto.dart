import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../chat/data/dtos/chat_response_dto.dart';

part 'home_response_dto.freezed.dart';
part 'home_response_dto.g.dart';

// Wire models of the read-only account endpoints. They share the Chat API's
// money, transaction and metadata shapes; enum values stay strings here and
// are decoded by the domain mapper.

/// `GET /accounts` response.
@freezed
abstract class AccountsResponseDto with _$AccountsResponseDto {
  const factory AccountsResponseDto({
    required List<AccountDto> accounts,
    required ResponseMetadataDto metadata,
  }) = _AccountsResponseDto;

  factory AccountsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AccountsResponseDtoFromJson(json);
}

@freezed
abstract class AccountDto with _$AccountDto {
  const factory AccountDto({
    required String id,
    required String name,
    required MoneyDto balance,
    required String status,
  }) = _AccountDto;

  factory AccountDto.fromJson(Map<String, dynamic> json) =>
      _$AccountDtoFromJson(json);
}

/// `GET /transactions` response.
@freezed
abstract class TransactionsResponseDto with _$TransactionsResponseDto {
  const factory TransactionsResponseDto({
    required List<TransactionDto> transactions,
    required ResponseMetadataDto metadata,
  }) = _TransactionsResponseDto;

  factory TransactionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionsResponseDtoFromJson(json);
}
