// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the chat through the Chat use cases.
///
/// Failures are part of [ChatState], never thrown. Calls that do not apply to
/// the current state (an action without an active conversation, or while
/// another operation is in flight) are ignored.

@ProviderFor(ChatController)
final chatControllerProvider = ChatControllerProvider._();

/// Drives the chat through the Chat use cases.
///
/// Failures are part of [ChatState], never thrown. Calls that do not apply to
/// the current state (an action without an active conversation, or while
/// another operation is in flight) are ignored.
final class ChatControllerProvider
    extends $NotifierProvider<ChatController, ChatState> {
  /// Drives the chat through the Chat use cases.
  ///
  /// Failures are part of [ChatState], never thrown. Calls that do not apply to
  /// the current state (an action without an active conversation, or while
  /// another operation is in flight) are ignored.
  ChatControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatControllerHash();

  @$internal
  @override
  ChatController create() => ChatController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatState>(value),
    );
  }
}

String _$chatControllerHash() => r'1e02ac3c03b8d3603b97c4cbb5a92f77fe10618f';

/// Drives the chat through the Chat use cases.
///
/// Failures are part of [ChatState], never thrown. Calls that do not apply to
/// the current state (an action without an active conversation, or while
/// another operation is in flight) are ignored.

abstract class _$ChatController extends $Notifier<ChatState> {
  ChatState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatState, ChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatState, ChatState>,
              ChatState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
