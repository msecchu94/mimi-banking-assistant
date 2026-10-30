import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/failure.dart';
import '../domain/models/chat_reply.dart';
import '../domain/models/conversation.dart';

part 'chat_state.freezed.dart';

/// Presentation state of the chat.
///
/// The backend stays authoritative for conversational state; this only holds
/// what the screen renders and which operation is in flight.
@freezed
sealed class ChatState with _$ChatState {
  /// No conversation has been started.
  const factory ChatState.initial() = ChatInitial;

  /// The conversation is being started.
  const factory ChatState.starting() = ChatStarting;

  /// Starting failed; `start()` may be called again.
  const factory ChatState.startFailed(Failure failure) = ChatStartFailed;

  /// A conversation is active.
  ///
  /// [pendingAction] is the action in flight, if any; only one runs at a
  /// time. [lastFailure] is the latest action's failure, cleared when the
  /// next action starts. A failed action leaves [conversation] and
  /// [transcript] unchanged: FL-04 does not infer conversation lifecycle
  /// transitions from failure codes.
  const factory ChatState.active({
    required Conversation conversation,
    required List<ChatEntry> transcript,
    ChatAction? pendingAction,
    ChatActionFailure? lastFailure,
  }) = ChatActive;
}

extension ChatActiveView on ChatActive {
  /// The backend's latest reply, if any.
  ChatReply? get latestReply {
    for (final entry in transcript.reversed) {
      if (entry case AssistantReply(:final reply)) return reply;
    }
    return null;
  }

  /// The backend's latest conversational flow state.
  ConversationState get flowState =>
      latestReply?.conversationState ?? conversation.state;
}

/// An exchange shown in the chat, in order.
@freezed
sealed class ChatEntry with _$ChatEntry {
  /// Text the user sent; structured interactions add no user entry.
  const factory ChatEntry.userMessage(String text) = UserMessage;

  const factory ChatEntry.assistantReply(ChatReply reply) = AssistantReply;
}

/// A user action on an active conversation.
@freezed
sealed class ChatAction with _$ChatAction {
  const factory ChatAction.sendMessage(String message) = SendMessageAction;

  const factory ChatAction.confirm(String operationId) = ConfirmAction;

  const factory ChatAction.cancel() = CancelAction;

  const factory ChatAction.selectCard(String cardId) = SelectCardAction;
}

/// The [failure] of [action], kept so the UI can report it and, for example,
/// restore an unsent message.
@freezed
abstract class ChatActionFailure with _$ChatActionFailure {
  const factory ChatActionFailure({
    required ChatAction action,
    required Failure failure,
  }) = _ChatActionFailure;
}
