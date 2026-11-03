import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../models/chat_reply.dart';
import '../repositories/chat_repository.dart';

/// Sends a free-text message; the backend interprets it.
class SendMessage {
  const SendMessage(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatReply>> call({
    required String conversationId,
    required String message,
  }) =>
      _repository.sendMessage(conversationId: conversationId, message: message);
}
