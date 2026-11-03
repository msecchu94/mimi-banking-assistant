import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/features/chat/domain/usecases/start_conversation.dart';

import 'fake_chat_repository.dart';

void main() {
  group('StartConversation', () {
    verifyUseCase(
      run: (repository) => StartConversation(repository)(),
      value: conversation,
      expected: (method: 'startConversation', arguments: {}),
    );
  });
}
