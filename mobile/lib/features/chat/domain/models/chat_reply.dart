import 'package:freezed_annotation/freezed_annotation.dart';

import 'chat_ui.dart';
import 'conversation.dart';

part 'chat_reply.freezed.dart';

/// The backend's reply to one message or interaction.
@freezed
abstract class ChatReply with _$ChatReply {
  const factory ChatReply({
    required String conversationId,

    /// The text to show.
    required String message,
    required ChatIntent intent,
    required ConversationState conversationState,
    required ChatUi ui,
  }) = _ChatReply;
}

/// The backend's interpretation of the request.
///
/// Informative only: it never authorizes client-side banking behavior.
enum ChatIntent {
  getBalance,
  getTransactions,
  analyzeExpenses,
  compareExpenses,
  getCards,
  freezeCard,
  unfreezeCard,
  getBeneficiaries,
  transferMoney,
  generalConversation,
  cancel,
  unknown,
}
