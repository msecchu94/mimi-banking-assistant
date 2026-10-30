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
