import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../models/conversation.dart';
import '../repositories/chat_repository.dart';

/// Starts a new conversation on the backend.
class StartConversation {
  const StartConversation(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, Conversation>> call() =>
      _repository.startConversation();
}
