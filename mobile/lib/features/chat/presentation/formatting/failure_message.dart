import '../../../../core/error/failure.dart';

/// What the user is told about a failed request.
String failureMessage(Failure failure) => switch (failure) {
  ConnectionFailure() =>
    'No pudimos conectarnos. Revisá tu conexión e intentá de nuevo.',
  BackendFailure(:final code) => switch (code) {
    BackendErrorCode.conversationNotFound ||
    BackendErrorCode.conversationClosed =>
      'Esta conversación ya no está disponible.',
    BackendErrorCode.insufficientFunds =>
      'No tenés saldo suficiente para esta operación.',
    BackendErrorCode.invalidAmount => 'El monto indicado no es válido.',
    BackendErrorCode.invalidCardState =>
      'La tarjeta no permite esta operación en su estado actual.',
    BackendErrorCode.pendingOperationConflict =>
      'Tenés una operación pendiente. Confirmala o cancelala primero.',
    BackendErrorCode.cardNotFound ||
    BackendErrorCode.beneficiaryNotFound ||
    BackendErrorCode.accountNotFound => 'No encontramos lo que pediste.',
    _ => _generic,
  },
  _ => _generic,
};

/// Whether the conversation can no longer continue, so the user needs a new
/// one to keep talking to Mimi.
bool endsConversation(Failure failure) => switch (failure) {
  BackendFailure(
    code: BackendErrorCode.conversationNotFound ||
        BackendErrorCode.conversationClosed,
  ) =>
    true,
  _ => false,
};

const _generic = 'No pudimos completar tu pedido. Intentá de nuevo.';
