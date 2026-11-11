import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/home/domain/models/home_summary.dart';
import 'package:mimi/features/home/domain/usecases/get_home_summary.dart';

import '../../home_fixtures.dart';

void main() {
  test('loads the ARS account and its 3 newest transactions', () async {
    final repository = FakeHomeRepository();

    final result = await GetHomeSummary(repository)();

    final summary = result.getOrElse((failure) => fail('$failure'));
    expect(summary.account, savings);
    expect(summary.recentTransactions, recentTransactions());
    expect(repository.transactionRequests, [(accountId: savingsId, limit: 3)]);
  });

  test('fails without an ARS account, without loading transactions', () async {
    final repository = FakeHomeRepository(accounts: Right([dollars]));

    expect(
      await GetHomeSummary(repository)(),
      const Left<Failure, HomeSummary>(NoArsAccountFailure()),
    );
    expect(repository.transactionRequests, isEmpty);
  });

  test('returns the accounts failure', () async {
    final repository = FakeHomeRepository(
      accounts: const Left(ConnectionFailure()),
    );

    expect(
      await GetHomeSummary(repository)(),
      const Left<Failure, HomeSummary>(ConnectionFailure()),
    );
    expect(repository.transactionRequests, isEmpty);
  });

  test('returns the transactions failure', () async {
    const failure = BackendFailure(
      code: BackendErrorCode.internalError,
      requestId: 'r-1',
    );
    final repository = FakeHomeRepository(transactions: const Left(failure));

    expect(
      await GetHomeSummary(repository)(),
      const Left<Failure, HomeSummary>(failure),
    );
  });
}
