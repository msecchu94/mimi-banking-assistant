import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/domain/models/chat_reply.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/conversation.dart';
import 'package:mimi/features/chat/presentation/chat_state.dart';

const _conversation = Conversation(
  id: '9e47b4c1-4a8c-4a3c-98d2-a31c9c87e641',
  state: ConversationState.ready,
);

ChatReply _reply(String message) => ChatReply(
  conversationId: _conversation.id,
  message: message,
  intent: ChatIntent.generalConversation,
  conversationState: ConversationState.ready,
  ui: const ChatUi.text(),
);

ChatActive _active(List<ChatEntry> transcript, {ChatActionFailure? failure}) =>
    ChatState.active(
      conversation: _conversation,
      transcript: transcript,
      lastFailure: failure,
    ) as ChatActive;

void main() {
  group('latestReplyIndex', () {
    test('is null without replies', () {
      expect(_active(const []).latestReplyIndex, isNull);
      expect(
        _active(const [ChatEntry.userMessage('Hola')]).latestReplyIndex,
        isNull,
      );
    });

    test('is the last assistant reply among interleaved entries', () {
      final state = _active([
        const ChatEntry.userMessage('Congelá mi tarjeta'),
        ChatEntry.assistantReply(_reply('¿Qué tarjeta?')),
        ChatEntry.assistantReply(_reply('¿Confirmás?')),
        const ChatEntry.userMessage('Hola'),
      ]);

      expect(state.latestReplyIndex, 2);
    });

    test('marks only the latest of identical replies as current', () {
      final state = _active([
        ChatEntry.assistantReply(_reply('¿Confirmás?')),
        const ChatEntry.userMessage('No, mejor a Diego'),
        ChatEntry.assistantReply(_reply('¿Confirmás?')),
      ]);

      expect(state.transcript[0], state.transcript[2]);
      expect(state.latestReplyIndex, 2);
    });

    test('is unchanged by a failed action', () {
      final transcript = [ChatEntry.assistantReply(_reply('¿Confirmás?'))];
      final failed = _active(
        transcript,
        failure: const ChatActionFailure(
          action: ChatAction.confirm('5b0c7d2e-3f41-4a6b-9c8d-1e2f3a4b5c6d'),
          failure: ConnectionFailure(),
        ),
      );

      expect(failed.latestReplyIndex, _active(transcript).latestReplyIndex);
      expect(failed.latestReplyIndex, 0);
    });
  });

  test('latestReply is the reply at latestReplyIndex', () {
    final latest = _reply('Listo');
    final state = _active([
      ChatEntry.assistantReply(_reply('¿Confirmás?')),
      ChatEntry.assistantReply(latest),
      const ChatEntry.userMessage('Gracias'),
    ]);

    expect(state.latestReply, latest);
    expect(
      state.transcript[state.latestReplyIndex!],
      ChatEntry.assistantReply(latest),
    );
    expect(_active(const []).latestReply, isNull);
  });
}
