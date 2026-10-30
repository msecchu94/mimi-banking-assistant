import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../models/chat_reply.dart';
import '../repositories/chat_repository.dart';

/// Confirms the operation waiting for confirmation under `operationId`.
///
/// The backend revalidates and executes it; confirming does not authorize
/// anything locally.
class ConfirmInteraction {
  const ConfirmInteraction(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatReply>> call({
    required String conversationId,
    required String operationId,
  }) => _repository.confirm(
    conversationId: conversationId,
    operationId: operationId,
  );
}
