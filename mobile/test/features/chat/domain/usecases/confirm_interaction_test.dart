import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/features/chat/domain/usecases/confirm_interaction.dart';

import 'fake_chat_repository.dart';

const _operationId = '5b0c7d2e-3f41-4a6b-9c8d-1e2f3a4b5c6d';

void main() {
  group('ConfirmInteraction', () {
    verifyUseCase(
      run: (repository) => ConfirmInteraction(repository)(
        conversationId: conversationId,
        operationId: _operationId,
      ),
      value: reply,
      expected: (
        method: 'confirm',
        arguments: {
          'conversationId': conversationId,
          'operationId': _operationId,
        },
      ),
    );
  });
}
