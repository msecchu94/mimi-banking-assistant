import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/features/chat/domain/usecases/select_card.dart';

import 'fake_chat_repository.dart';

const _cardId = '16e39f21-93b5-48b5-a8dc-90ad03ea5dd1';

void main() {
  group('SelectCard', () {
    verifyUseCase(
      run: (repository) => SelectCard(repository)(
        conversationId: conversationId,
        cardId: _cardId,
      ),
      value: reply,
      expected: (
        method: 'selectCard',
        arguments: {'conversationId': conversationId, 'cardId': _cardId},
      ),
    );
  });
}
