// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeApiClient)
final homeApiClientProvider = HomeApiClientProvider._();

final class HomeApiClientProvider
    extends $FunctionalProvider<HomeApiClient, HomeApiClient, HomeApiClient>
    with $Provider<HomeApiClient> {
  HomeApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeApiClientHash();

  @$internal
  @override
  $ProviderElement<HomeApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeApiClient create(Ref ref) {
    return homeApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeApiClient>(value),
    );
  }
}

String _$homeApiClientHash() => r'9103d43b798e4863d0ed82f441cb39066ad1139e';

@ProviderFor(homeRemoteDataSource)
final homeRemoteDataSourceProvider = HomeRemoteDataSourceProvider._();

final class HomeRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          HomeRemoteDataSource,
          HomeRemoteDataSource,
          HomeRemoteDataSource
        >
    with $Provider<HomeRemoteDataSource> {
  HomeRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<HomeRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeRemoteDataSource create(Ref ref) {
    return homeRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRemoteDataSource>(value),
    );
  }
}

String _$homeRemoteDataSourceHash() =>
    r'352800618b9ba70251c68340e666ba92585d7fca';

/// Binds [HomeRepository] to [HomeRepositoryImpl].

@ProviderFor(homeRepository)
final homeRepositoryProvider = HomeRepositoryProvider._();

/// Binds [HomeRepository] to [HomeRepositoryImpl].

final class HomeRepositoryProvider
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
  /// Binds [HomeRepository] to [HomeRepositoryImpl].
  HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'23ec48b4620b4ff6b84956cfbc542370faf7a28e';

@ProviderFor(getHomeSummary)
final getHomeSummaryProvider = GetHomeSummaryProvider._();

final class GetHomeSummaryProvider
    extends $FunctionalProvider<GetHomeSummary, GetHomeSummary, GetHomeSummary>
    with $Provider<GetHomeSummary> {
  GetHomeSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getHomeSummaryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getHomeSummaryHash();

  @$internal
  @override
  $ProviderElement<GetHomeSummary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetHomeSummary create(Ref ref) {
    return getHomeSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetHomeSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetHomeSummary>(value),
    );
  }
}

String _$getHomeSummaryHash() => r'148bc09d5745d02143e2249c442f0f9a857f4c1f';
