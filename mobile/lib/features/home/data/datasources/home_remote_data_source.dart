import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/network_exception.dart';
import '../dtos/home_response_dto.dart';
import 'home_api_client.dart';

/// Remote account data, behind the network boundary.
///
/// Every failure surfaces as a [NetworkException]; Dio and decoding errors do
/// not escape this class.
class HomeRemoteDataSource {
  HomeRemoteDataSource(this._client);

  final HomeApiClient _client;

  Future<AccountsResponseDto> getAccounts() => _guard(_client.getAccounts);

  Future<TransactionsResponseDto> getTransactions({
    required String accountId,
    required int limit,
  }) =>
      _guard(() => _client.getTransactions(accountId: accountId, limit: limit));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapDioException(error);
    } on CheckedFromJsonException catch (cause) {
      throw InvalidResponseException(cause: cause);
    } on FormatException catch (cause) {
      throw InvalidResponseException(cause: cause);
    }
  }
}
