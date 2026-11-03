/// Base type for expected, application-level failures.
///
/// Use cases return `Either<Failure, T>` (fpdart). Features define concrete
/// failures by extending this type; transport errors and DTOs must be mapped
/// to a [Failure] in the Data layer and never reach Presentation.
abstract class Failure {
  const Failure();
}

/// The backend could not be reached or did not answer in time.
final class ConnectionFailure extends Failure {
  const ConnectionFailure();

  @override
  bool operator ==(Object other) => other is ConnectionFailure;

  @override
  int get hashCode => (ConnectionFailure).hashCode;

  @override
  String toString() => 'ConnectionFailure()';
}

/// The backend rejected the request with a stable error [code].
///
/// [requestId] correlates the failure with backend logs.
final class BackendFailure extends Failure {
  const BackendFailure({required this.code, required this.requestId});

  final BackendErrorCode code;
  final String requestId;

  @override
  bool operator ==(Object other) =>
      other is BackendFailure &&
      other.code == code &&
      other.requestId == requestId;

  @override
  int get hashCode => Object.hash(code, requestId);

  @override
  String toString() => 'BackendFailure(code: $code, requestId: $requestId)';
}

/// The request failed in a way the client cannot interpret, such as a
/// response outside the API contract.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();

  @override
  bool operator ==(Object other) => other is UnexpectedFailure;

  @override
  int get hashCode => (UnexpectedFailure).hashCode;

  @override
  String toString() => 'UnexpectedFailure()';
}

/// The stable error codes of the backend API contract.
///
/// The backend may add codes; one this client does not know is [unknown].
enum BackendErrorCode {
  invalidRequest,
  invalidInteraction,
  conversationNotFound,
  conversationClosed,
  accountNotFound,
  cardNotFound,
  beneficiaryNotFound,
  insufficientFunds,
  invalidAmount,
  invalidAccountState,
  invalidCardState,
  pendingOperationConflict,
  invalidConversationState,
  internalError,
  serviceUnavailable,
  unknown,
}
