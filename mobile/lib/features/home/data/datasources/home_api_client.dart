import 'package:dio/dio.dart';

import '../dtos/home_response_dto.dart';

/// HTTP calls of the read-only account endpoints.
///
/// Throws [DioException] for transport and HTTP errors, and
/// `CheckedFromJsonException` or [FormatException] for a body outside the
/// contract; `HomeRemoteDataSource` classifies them.
class HomeApiClient {
  HomeApiClient(this._dio);

  final Dio _dio;

  /// `GET /accounts`.
  Future<AccountsResponseDto> getAccounts() async {
    final response = await _dio.get<Object?>('/accounts');
    return AccountsResponseDto.fromJson(_jsonObject(response.data));
  }

  /// `GET /transactions?account_id=…&limit=…`.
  Future<TransactionsResponseDto> getTransactions({
    required String accountId,
    required int limit,
  }) async {
    final response = await _dio.get<Object?>(
      '/transactions',
      queryParameters: {'account_id': accountId, 'limit': limit},
    );
    return TransactionsResponseDto.fromJson(_jsonObject(response.data));
  }

  Map<String, dynamic> _jsonObject(Object? body) => body is Map<String, dynamic>
      ? body
      : throw FormatException('Expected a JSON object', body);
}
