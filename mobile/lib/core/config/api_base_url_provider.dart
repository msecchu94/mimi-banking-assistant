import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_base_url_provider.g.dart';

/// The backend base URL resolved at bootstrap.
///
/// Must be overridden at the composition root (`main.dart`) or in tests.
@Riverpod(keepAlive: true)
Uri apiBaseUrl(Ref ref) =>
    throw StateError('apiBaseUrlProvider must be overridden at bootstrap');
