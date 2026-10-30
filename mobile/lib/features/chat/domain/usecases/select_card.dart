import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../models/chat_reply.dart';
import '../repositories/chat_repository.dart';

/// Selects the card the backend asked for to continue the pending operation.
class SelectCard {
  const SelectCard(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatReply>> call({
    required String conversationId,
    required String cardId,
  }) => _repository.selectCard(conversationId: conversationId, cardId: cardId);
}
