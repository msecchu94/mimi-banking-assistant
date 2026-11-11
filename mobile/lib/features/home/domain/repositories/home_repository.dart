import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../chat/domain/models/chat_ui.dart';
import '../models/account.dart';

/// Read-only access to the customer's persisted accounts and transactions.
abstract interface class HomeRepository {
  Future<Either<Failure, List<Account>>> getAccounts();

  /// The newest [limit] transactions of [accountId], newest first.
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    required String accountId,
    required int limit,
  });
}
