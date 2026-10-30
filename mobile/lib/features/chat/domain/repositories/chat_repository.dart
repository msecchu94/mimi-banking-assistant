import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../models/chat_reply.dart';
import '../models/conversation.dart';

/// Access to the backend Chat API.
///
/// The backend owns interpretation, validation and execution; every call
/// returns its result or a [Failure].
abstract interface class ChatRepository {
  Future<Either<Failure, Conversation>> startConversation();

  Future<Either<Failure, ChatReply>> sendMessage({
    required String conversationId,
    required String message,
  });

  /// Authorizes only the operation waiting for confirmation under
  /// [operationId].
  Future<Either<Failure, ChatReply>> confirm({
    required String conversationId,
    required String operationId,
  });

  /// Cancels the pending operation, if any.
  Future<Either<Failure, ChatReply>> cancel({required String conversationId});

  Future<Either<Failure, ChatReply>> selectCard({
    required String conversationId,
    required String cardId,
  });
}
