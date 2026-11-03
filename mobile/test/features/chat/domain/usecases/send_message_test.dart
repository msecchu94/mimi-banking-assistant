import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/features/chat/domain/usecases/send_message.dart';

import 'fake_chat_repository.dart';

void main() {
  group('SendMessage', () {
    verifyUseCase(
      run: (repository) => SendMessage(repository)(
        conversationId: conversationId,
        message: 'Transferile 25000 a Laura',
      ),
      value: reply,
      expected: (
        method: 'sendMessage',
        arguments: {
          'conversationId': conversationId,
          'message': 'Transferile 25000 a Laura',
        },
      ),
    );
  });
}
