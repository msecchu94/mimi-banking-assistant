// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatApiClient)
final chatApiClientProvider = ChatApiClientProvider._();

final class ChatApiClientProvider
    extends $FunctionalProvider<ChatApiClient, ChatApiClient, ChatApiClient>
    with $Provider<ChatApiClient> {
  ChatApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatApiClientHash();

  @$internal
  @override
  $ProviderElement<ChatApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatApiClient create(Ref ref) {
    return chatApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatApiClient>(value),
    );
  }
}

String _$chatApiClientHash() => r'76dbff920745af91a0499c879fe7424598871821';

@ProviderFor(chatRemoteDataSource)
final chatRemoteDataSourceProvider = ChatRemoteDataSourceProvider._();

final class ChatRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ChatRemoteDataSource,
          ChatRemoteDataSource,
          ChatRemoteDataSource
        >
    with $Provider<ChatRemoteDataSource> {
  ChatRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ChatRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChatRemoteDataSource create(Ref ref) {
    return chatRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRemoteDataSource>(value),
    );
  }
}

String _$chatRemoteDataSourceHash() =>
    r'b038e130a2da8ee7cd207600e1bf05ba25644f25';

/// Binds [ChatRepository] to [ChatRepositoryImpl].

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

/// Binds [ChatRepository] to [ChatRepositoryImpl].

final class ChatRepositoryProvider
    extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  /// Binds [ChatRepository] to [ChatRepositoryImpl].
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'fe65d2f67d590dc92b35d8d2e3aad250b71809f9';

@ProviderFor(startConversation)
final startConversationProvider = StartConversationProvider._();

final class StartConversationProvider
    extends
        $FunctionalProvider<
          StartConversation,
          StartConversation,
          StartConversation
        >
    with $Provider<StartConversation> {
  StartConversationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startConversationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startConversationHash();

  @$internal
  @override
  $ProviderElement<StartConversation> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StartConversation create(Ref ref) {
    return startConversation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartConversation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartConversation>(value),
    );
  }
}

String _$startConversationHash() => r'cf4af4ddbda9c22db9594ea40aac90e45f60e7b7';

@ProviderFor(sendMessage)
final sendMessageProvider = SendMessageProvider._();

final class SendMessageProvider
    extends $FunctionalProvider<SendMessage, SendMessage, SendMessage>
    with $Provider<SendMessage> {
  SendMessageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendMessageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendMessageHash();

  @$internal
  @override
  $ProviderElement<SendMessage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SendMessage create(Ref ref) {
    return sendMessage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendMessage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendMessage>(value),
    );
  }
}

String _$sendMessageHash() => r'f542065dd8300289e010712dca50d1b8cd5adcad';

@ProviderFor(confirmInteraction)
final confirmInteractionProvider = ConfirmInteractionProvider._();

final class ConfirmInteractionProvider
    extends
        $FunctionalProvider<
          ConfirmInteraction,
          ConfirmInteraction,
          ConfirmInteraction
        >
    with $Provider<ConfirmInteraction> {
  ConfirmInteractionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'confirmInteractionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$confirmInteractionHash();

  @$internal
  @override
  $ProviderElement<ConfirmInteraction> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConfirmInteraction create(Ref ref) {
    return confirmInteraction(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfirmInteraction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfirmInteraction>(value),
    );
  }
}

String _$confirmInteractionHash() =>
    r'ebbd7ae277a914fb95c5a9402fd335ce06cb0c1e';

@ProviderFor(cancelInteraction)
final cancelInteractionProvider = CancelInteractionProvider._();

final class CancelInteractionProvider
    extends
        $FunctionalProvider<
          CancelInteraction,
          CancelInteraction,
          CancelInteraction
        >
    with $Provider<CancelInteraction> {
  CancelInteractionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelInteractionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelInteractionHash();

  @$internal
  @override
  $ProviderElement<CancelInteraction> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CancelInteraction create(Ref ref) {
    return cancelInteraction(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelInteraction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelInteraction>(value),
    );
  }
}

String _$cancelInteractionHash() => r'7ff2f6bdede46e099730c8540353086d09a1c046';

@ProviderFor(selectCard)
final selectCardProvider = SelectCardProvider._();

final class SelectCardProvider
    extends $FunctionalProvider<SelectCard, SelectCard, SelectCard>
    with $Provider<SelectCard> {
  SelectCardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectCardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectCardHash();

  @$internal
  @override
  $ProviderElement<SelectCard> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SelectCard create(Ref ref) {
    return selectCard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectCard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectCard>(value),
    );
  }
}

String _$selectCardHash() => r'a2d6b1ce6699c8712f8a76721ad9d0b5aed382f6';
