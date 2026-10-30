/// Base URL of the Mimi backend API.
///
/// Selected at build time with `--dart-define-from-file=config/<env>.json`.
/// There is no default: an environment without a resolved backend keeps the
/// value empty, and the app refuses to start against it.
abstract final class ApiBaseUrl {
  static const String defineKey = 'API_BASE_URL';

  /// Resolves the base URL from the `API_BASE_URL` compile-time define.
  ///
  /// Throws an [ArgumentError] when the define is missing or invalid.
  static Uri fromDefines() => parse(const String.fromEnvironment(defineKey));

  /// Parses an absolute `http`/`https` URL without query or fragment.
  static Uri parse(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError.value(
        value,
        defineKey,
        'Expected an absolute http(s) URL. '
        'Run with --dart-define-from-file=config/<env>.json',
      );
    }
    return uri;
  }
}
