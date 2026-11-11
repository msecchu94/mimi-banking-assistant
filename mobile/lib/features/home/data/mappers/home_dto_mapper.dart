import '../../../../core/network/network_exception.dart';
import '../../../../core/network/wire_enum.dart';
import '../../../chat/data/mappers/chat_dto_mapper.dart';
import '../../../chat/domain/models/chat_ui.dart';
import '../../domain/models/account.dart';
import '../dtos/home_response_dto.dart';

// Explicit DTO → Domain mapping. A value outside the contract is an
// InvalidResponseException.

List<Account> accountsFromDto(AccountsResponseDto dto) => [
  for (final account in dto.accounts) _account(account),
];

List<Transaction> transactionsFromDto(TransactionsResponseDto dto) => [
  for (final transaction in dto.transactions) transactionFromDto(transaction),
];

Account _account(AccountDto dto) => Account(
  id: dto.id,
  name: dto.name,
  balance: moneyFromDto(dto.balance),
  status:
      decodeWireEnum(AccountStatus.values, dto.status) ??
      (throw InvalidResponseException(
        cause: FormatException('Unknown AccountStatus value', dto.status),
      )),
);
