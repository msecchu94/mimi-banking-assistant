import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/features/chat/domain/usecases/cancel_interaction.dart';

import 'fake_chat_repository.dart';

void main() {
  group('CancelInteraction', () {
    verifyUseCase(
      run: (repository) =>
          CancelInteraction(repository)(conversationId: conversationId),
      value: reply,
      expected: (
        method: 'cancel',
        arguments: {'conversationId': conversationId},
      ),
    );
  });
}
