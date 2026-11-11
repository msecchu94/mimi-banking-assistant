import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../models/home_summary.dart';
import '../repositories/home_repository.dart';

/// Loads the ARS account and its newest transactions for Home.
///
/// The first ARS account in backend order is used; without one, the result
/// is a [NoArsAccountFailure].
class GetHomeSummary {
  const GetHomeSummary(this._repository);

  static const recentTransactionsLimit = 3;

  final HomeRepository _repository;

  Future<Either<Failure, HomeSummary>> call() async {
    final accounts = await _repository.getAccounts();
    if (accounts case Left(value: final failure)) return Left(failure);

    final account = accounts
        .getOrElse((_) => const [])
        .where((account) => account.isArs)
        .firstOrNull;
    if (account == null) return const Left(NoArsAccountFailure());

    final transactions = await _repository.getRecentTransactions(
      accountId: account.id,
      limit: recentTransactionsLimit,
    );
    return transactions.map(
      (transactions) =>
          HomeSummary(account: account, recentTransactions: transactions),
    );
  }
}
