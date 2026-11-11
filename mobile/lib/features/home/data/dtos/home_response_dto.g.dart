// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountsResponseDto _$AccountsResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AccountsResponseDto', json, ($checkedConvert) {
      final val = _AccountsResponseDto(
        accounts: $checkedConvert(
          'accounts',
          (v) => (v as List<dynamic>)
              .map((e) => AccountDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        metadata: $checkedConvert(
          'metadata',
          (v) => ResponseMetadataDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AccountsResponseDtoToJson(
  _AccountsResponseDto instance,
) => <String, dynamic>{
  'accounts': instance.accounts.map((e) => e.toJson()).toList(),
  'metadata': instance.metadata.toJson(),
};

_AccountDto _$AccountDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AccountDto', json, ($checkedConvert) {
      final val = _AccountDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        balance: $checkedConvert(
          'balance',
          (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
        ),
        status: $checkedConvert('status', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AccountDtoToJson(_AccountDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance.toJson(),
      'status': instance.status,
    };

_TransactionsResponseDto _$TransactionsResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_TransactionsResponseDto', json, ($checkedConvert) {
  final val = _TransactionsResponseDto(
    transactions: $checkedConvert(
      'transactions',
      (v) => (v as List<dynamic>)
          .map((e) => TransactionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    metadata: $checkedConvert(
      'metadata',
      (v) => ResponseMetadataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$TransactionsResponseDtoToJson(
  _TransactionsResponseDto instance,
) => <String, dynamic>{
  'transactions': instance.transactions.map((e) => e.toJson()).toList(),
  'metadata': instance.metadata.toJson(),
};
