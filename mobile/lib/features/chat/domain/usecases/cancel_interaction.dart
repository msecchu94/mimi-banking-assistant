import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../models/chat_reply.dart';
import '../repositories/chat_repository.dart';

/// Cancels the conversation's pending operation, if any.
class CancelInteraction {
  const CancelInteraction(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatReply>> call({required String conversationId}) =>
      _repository.cancel(conversationId: conversationId);
}
