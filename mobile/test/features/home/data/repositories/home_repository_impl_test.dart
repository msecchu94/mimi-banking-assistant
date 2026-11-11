import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/money.dart';
import 'package:mimi/features/home/data/datasources/home_api_client.dart';
import 'package:mimi/features/home/data/datasources/home_remote_data_source.dart';
import 'package:mimi/features/home/data/repositories/home_repository_impl.dart';
import 'package:mimi/features/home/domain/models/account.dart';

import '../../../../helpers/fake_http_client_adapter.dart';
import '../../home_fixtures.dart';

const _metadata = {'request_id': 'req-1', 'timestamp': '2026-10-09T16:30:00Z'};

Map<String, dynamic> _accountJson({String status = 'ACTIVE'}) => {
  'id': savingsId,
  'name': 'Caja de ahorro',
  'balance': {'amount': '1284650.75', 'currency': 'ARS'},
  'status': status,
};

const _transactionJson = {
  'id': 't-1',
  'description': 'Supermercado Día',
  'amount': {'amount': '32480.50', 'currency': 'ARS'},
  'type': 'DEBIT',
  'category': 'GROCERIES',
  'occurred_at': '2026-10-09T15:42:00Z',
};

(HomeRepositoryImpl, FakeHttpClientAdapter) _repository(
  FakeHttpClientAdapter adapter,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'))
    ..httpClientAdapter = adapter;
  return (
    HomeRepositoryImpl(HomeRemoteDataSource(HomeApiClient(dio))),
    adapter,
  );
}

void main() {
  test('reads the accounts with exact balances', () async {
    final (repository, adapter) = _repository(
      FakeHttpClientAdapter.json(200, {
        'accounts': [_accountJson()],
        'metadata': _metadata,
      }),
    );

    final accounts = (await repository.getAccounts()).getOrElse(
      (failure) => fail('$failure'),
    );

    expect(accounts, [savings]);
    expect(accounts.single.balance.amount, '1284650.75');
    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, '/accounts');
  });

  test('reads the newest transactions of one account', () async {
    final (repository, adapter) = _repository(
      FakeHttpClientAdapter.json(200, {
        'transactions': [_transactionJson],
        'metadata': _metadata,
      }),
    );

    final result = await repository.getRecentTransactions(
      accountId: savingsId,
      limit: 3,
    );

    expect(result.getOrElse((failure) => fail('$failure')), [
      Transaction(
        id: 't-1',
        description: 'Supermercado Día',
        amount: Money(amount: '32480.50', currency: Currency.ars),
        type: TransactionType.debit,
        category: TransactionCategory.groceries,
        occurredAt: DateTime.utc(2026, 10, 9, 15, 42),
      ),
    ]);
    final request = adapter.requests.single;
    expect(request.path, '/transactions');
    expect(request.queryParameters, {'account_id': savingsId, 'limit': 3});
  });

  test('maps an API error to a BackendFailure', () async {
    final (repository, _) = _repository(
      FakeHttpClientAdapter.json(500, {
        'code': 'INTERNAL_ERROR',
        'message': 'An unexpected error occurred.',
        'request_id': 'req-9',
        'timestamp': '2026-10-09T16:30:00Z',
      }),
    );

    expect(
      await repository.getAccounts(),
      const Left<Failure, List<Account>>(
        BackendFailure(
          code: BackendErrorCode.internalError,
          requestId: 'req-9',
        ),
      ),
    );
  });

  test('maps an unreachable backend to a ConnectionFailure', () async {
    final (repository, _) = _repository(
      FakeHttpClientAdapter.failing(
        (options) => DioException.connectionError(
          requestOptions: options,
          reason: 'refused',
        ),
      ),
    );

    expect(
      await repository.getRecentTransactions(accountId: savingsId, limit: 3),
      const Left<Failure, List<Transaction>>(ConnectionFailure()),
    );
  });

  for (final (name, body) in [
    ('a body outside the contract', {'accounts': 'nope'}),
    (
      'an unknown account status',
      {
        'accounts': [_accountJson(status: 'CLOSED')],
        'metadata': _metadata,
      },
    ),
    (
      'a malformed balance',
      {
        'accounts': [
          {
            ..._accountJson(),
            'balance': {'amount': '12.5', 'currency': 'ARS'},
          },
        ],
        'metadata': _metadata,
      },
    ),
  ]) {
    test('maps $name to an UnexpectedFailure', () async {
      final (repository, _) = _repository(
        FakeHttpClientAdapter.json(200, body),
      );

      expect(
        await repository.getAccounts(),
        const Left<Failure, List<Account>>(UnexpectedFailure()),
      );
    });
  }
}
