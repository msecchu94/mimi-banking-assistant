import '../network/network_exception.dart';
import '../network/wire_enum.dart';
import 'failure.dart';

/// Exposes an infrastructure [NetworkException] as an application [Failure].
Failure mapNetworkException(NetworkException exception) => switch (exception) {
  ConnectionException() => const ConnectionFailure(),
  ApiErrorException(:final code, :final requestId) => BackendFailure(
    code:
        decodeWireEnum(BackendErrorCode.values, code) ??
        BackendErrorCode.unknown,
    requestId: requestId,
  ),
  InvalidResponseException() ||
  UnknownNetworkException() => const UnexpectedFailure(),
};
