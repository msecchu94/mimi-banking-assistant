// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_base_url_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The backend base URL resolved at bootstrap.
///
/// Must be overridden at the composition root (`main.dart`) or in tests.

@ProviderFor(apiBaseUrl)
final apiBaseUrlProvider = ApiBaseUrlProvider._();

/// The backend base URL resolved at bootstrap.
///
/// Must be overridden at the composition root (`main.dart`) or in tests.

final class ApiBaseUrlProvider extends $FunctionalProvider<Uri, Uri, Uri>
    with $Provider<Uri> {
  /// The backend base URL resolved at bootstrap.
  ///
  /// Must be overridden at the composition root (`main.dart`) or in tests.
  ApiBaseUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiBaseUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiBaseUrlHash();

  @$internal
  @override
  $ProviderElement<Uri> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uri create(Ref ref) {
    return apiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri>(value),
    );
  }
}

String _$apiBaseUrlHash() => r'008c78885e531837cdfe084708509a457a7e7f62';
