import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';

/// A conversation started on the backend.
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required ConversationState state,
  }) = _Conversation;
}

/// The backend's authoritative conversational flow state.
///
/// Informative for presentation; the client never advances it.
enum ConversationState { ready, collectingData, waitingConfirmation }
