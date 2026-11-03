/// Infrastructure error raised by the HTTP layer.
///
/// Data-layer only: repositories map it to a `Failure`, so it never reaches
/// Domain or Presentation.
sealed class NetworkException implements Exception {
  const NetworkException();
}

/// The backend could not be reached or did not answer in time.
final class ConnectionException extends NetworkException {
  const ConnectionException();

  @override
  String toString() => 'ConnectionException()';
}

/// The backend answered with an error in the contract's `ApiErrorResponse`
/// shape.
final class ApiErrorException extends NetworkException {
  const ApiErrorException({
    required this.statusCode,
    required this.code,
    required this.requestId,
  });

  final int statusCode;

  /// The stable, machine-readable error code.
  final String code;

  final String requestId;

  @override
  String toString() =>
      'ApiErrorException(statusCode: $statusCode, code: $code, '
      'requestId: $requestId)';
}

/// The backend answered with a body outside the API contract.
final class InvalidResponseException extends NetworkException {
  const InvalidResponseException({this.statusCode, this.cause});

  /// The HTTP status, when the response had one.
  final int? statusCode;

  final Object? cause;

  @override
  String toString() =>
      'InvalidResponseException(statusCode: $statusCode, cause: $cause)';
}

/// Any other failure of the HTTP layer, such as a rejected certificate or a
/// cancelled request.
final class UnknownNetworkException extends NetworkException {
  const UnknownNetworkException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'UnknownNetworkException($cause)';
}
