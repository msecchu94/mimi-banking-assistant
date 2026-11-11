import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/money.dart';
import 'package:mimi/features/home/domain/models/account.dart';
import 'package:mimi/features/home/domain/repositories/home_repository.dart';

const savingsId = '11111111-1111-4111-8111-111111111111';
const dollarsId = '22222222-2222-4222-8222-222222222222';

final savings = Account(
  id: savingsId,
  name: 'Caja de ahorro',
  balance: Money(amount: '1284650.75', currency: Currency.ars),
  status: AccountStatus.active,
);

final dollars = Account(
  id: dollarsId,
  name: 'Caja de ahorro en dólares',
  balance: Money(amount: '2450.00', currency: Currency.usd),
  status: AccountStatus.active,
);

/// Today at [hour]:[minute] in the device's timezone, shifted [daysAgo].
DateTime localTime(int hour, int minute, {int daysAgo = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - daysAgo, hour, minute).toUtc();
}

/// The DS-04 Home transactions, as the backend would supply them.
List<Transaction> recentTransactions() => [
  Transaction(
    id: 't-1',
    description: 'Supermercado Día',
    amount: Money(amount: '32480.50', currency: Currency.ars),
    type: TransactionType.debit,
    category: TransactionCategory.groceries,
    occurredAt: localTime(12, 42),
  ),
  Transaction(
    id: 't-2',
    description: 'Martín López',
    amount: Money(amount: '85000.00', currency: Currency.ars),
    type: TransactionType.credit,
    category: TransactionCategory.transfer,
    occurredAt: localTime(10, 18),
  ),
  Transaction(
    id: 't-3',
    description: 'Personal',
    amount: Money(amount: '18900.00', currency: Currency.ars),
    type: TransactionType.debit,
    category: TransactionCategory.utilities,
    occurredAt: localTime(18, 5, daysAgo: 1),
  ),
];

/// Answers with programmed results and records the transaction requests.
class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    Either<Failure, List<Account>>? accounts,
    Either<Failure, List<Transaction>>? transactions,
  }) : accounts = accounts ?? Right([dollars, savings]),
       transactions = transactions ?? Right(recentTransactions());

  Either<Failure, List<Account>> accounts;
  Either<Failure, List<Transaction>> transactions;
  final List<({String accountId, int limit})> transactionRequests = [];
  int accountRequests = 0;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    accountRequests++;
    return accounts;
  }

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    required String accountId,
    required int limit,
  }) async {
    transactionRequests.add((accountId: accountId, limit: limit));
    return transactions;
  }
}

/// The transfer the backend persisted, as it reports it afterwards.
final persistedTransfer = Transaction(
  id: 't-new',
  description: 'Transferencia a Laura Gómez',
  amount: Money(amount: '1.00', currency: Currency.ars),
  type: TransactionType.debit,
  category: TransactionCategory.transfer,
  occurredAt: localTime(13, 5),
);

/// What the backend reports after [persistedTransfer]: its own balance and
/// its newest three transactions.
final savingsAfterTransfer = savings.copyWith(
  balance: Money(amount: '1284649.75', currency: Currency.ars),
);

List<Transaction> transactionsAfterTransfer() => [
  persistedTransfer,
  ...recentTransactions().take(2),
];

/// Answers like [FakeHomeRepository] and, while [gate] is set, holds each
/// accounts request until the gate completes.
class GatedHomeRepository extends FakeHomeRepository {
  Completer<void>? gate;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    if (gate case final gate?) {
      accountRequests++;
      await gate.future;
      return accounts;
    }
    return super.getAccounts();
  }
}
