import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/network_exception.dart';
import '../../../chat/domain/models/chat_ui.dart';
import '../../domain/models/account.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../mappers/home_dto_mapper.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() =>
      _run(() async => accountsFromDto(await _remote.getAccounts()));

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    required String accountId,
    required int limit,
  }) => _run(
    () async => transactionsFromDto(
      await _remote.getTransactions(accountId: accountId, limit: limit),
    ),
  );

  Future<Either<Failure, T>> _run<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on NetworkException catch (exception) {
      return Left(mapNetworkException(exception));
    }
  }
}
