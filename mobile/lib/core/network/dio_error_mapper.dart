import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import 'api_error_response_dto.dart';
import 'network_exception.dart';

/// Classifies a [DioException] as a [NetworkException].
///
/// The only place where Dio error types and HTTP error responses are
/// interpreted.
NetworkException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const ConnectionException();
    case DioExceptionType.badResponse:
      return _mapErrorResponse(error.response);
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.unknown:
      return UnknownNetworkException(error.error ?? error.type);
  }
}

NetworkException _mapErrorResponse(Response<Object?>? response) {
  final statusCode = response?.statusCode;
  final body = response?.data;
  if (statusCode == null || body is! Map<String, dynamic>) {
    return InvalidResponseException(statusCode: statusCode, cause: body);
  }
  try {
    final error = ApiErrorResponseDto.fromJson(body);
    return ApiErrorException(
      statusCode: statusCode,
      code: error.code,
      requestId: error.requestId,
    );
  } on CheckedFromJsonException catch (cause) {
    return InvalidResponseException(statusCode: statusCode, cause: cause);
  }
}
