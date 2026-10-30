import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failure.dart';
import '../chat_providers.dart';
import '../domain/models/chat_reply.dart';
import 'chat_state.dart';

part 'chat_controller.g.dart';

/// Drives the chat through the Chat use cases.
///
/// Failures are part of [ChatState], never thrown. Calls that do not apply to
/// the current state (an action without an active conversation, or while
/// another operation is in flight) are ignored.
@Riverpod(keepAlive: true)
class ChatController extends _$ChatController {
  @override
  ChatState build() => const ChatState.initial();

  /// Starts a conversation, replacing the active one, if any.
  Future<void> start() async {
    if (state is ChatStarting || _isBusy) return;
    state = const ChatState.starting();

    final result = await ref.read(startConversationProvider)();
    if (!ref.mounted) return;

    state = result.match(
      ChatState.startFailed,
      (conversation) =>
          ChatState.active(conversation: conversation, transcript: const []),
    );
  }

  Future<void> sendMessage(String message) => _run(
    ChatAction.sendMessage(message),
    (conversationId) => ref.read(sendMessageProvider)(
      conversationId: conversationId,
      message: message,
    ),
  );

  Future<void> confirm(String operationId) => _run(
    ChatAction.confirm(operationId),
    (conversationId) => ref.read(confirmInteractionProvider)(
      conversationId: conversationId,
      operationId: operationId,
    ),
  );

  Future<void> cancel() => _run(
    const ChatAction.cancel(),
    (conversationId) =>
        ref.read(cancelInteractionProvider)(conversationId: conversationId),
  );

  Future<void> selectCard(String cardId) => _run(
    ChatAction.selectCard(cardId),
    (conversationId) => ref.read(selectCardProvider)(
      conversationId: conversationId,
      cardId: cardId,
    ),
  );

  bool get _isBusy => switch (state) {
    ChatActive(:final pendingAction) => pendingAction != null,
    _ => false,
  };

  Future<void> _run(
    ChatAction action,
    Future<Either<Failure, ChatReply>> Function(String conversationId) call,
  ) async {
    final active = state;
    if (active is! ChatActive || active.pendingAction != null) return;
    state = active.copyWith(pendingAction: action, lastFailure: null);

    final result = await call(active.conversation.id);
    if (!ref.mounted) return;

    state = result.match(
      (failure) => active.copyWith(
        pendingAction: null,
        lastFailure: ChatActionFailure(action: action, failure: failure),
      ),
      (reply) => active.copyWith(
        transcript: [
          ...active.transcript,
          if (action case SendMessageAction(:final message))
            ChatEntry.userMessage(message),
          ChatEntry.assistantReply(reply),
        ],
        pendingAction: null,
        lastFailure: null,
      ),
    );
  }
}
