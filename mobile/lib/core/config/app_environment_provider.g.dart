// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_environment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The environment resolved at bootstrap.
///
/// Must be overridden at the composition root (`main.dart`) or in tests.

@ProviderFor(appEnvironment)
final appEnvironmentProvider = AppEnvironmentProvider._();

/// The environment resolved at bootstrap.
///
/// Must be overridden at the composition root (`main.dart`) or in tests.

final class AppEnvironmentProvider
    extends $FunctionalProvider<AppEnvironment, AppEnvironment, AppEnvironment>
    with $Provider<AppEnvironment> {
  /// The environment resolved at bootstrap.
  ///
  /// Must be overridden at the composition root (`main.dart`) or in tests.
  AppEnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appEnvironmentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appEnvironmentHash();

  @$internal
  @override
  $ProviderElement<AppEnvironment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppEnvironment create(Ref ref) {
    return appEnvironment(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppEnvironment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppEnvironment>(value),
    );
  }
}

String _$appEnvironmentHash() => r'910f078585a95c05b6afd9e269d10e5ebb4c2e84';
