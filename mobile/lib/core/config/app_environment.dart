/// Runtime environment the app was built for.
///
/// Selected at build time with `--dart-define-from-file=config/<env>.json`.
/// Add a value (e.g. `staging`) together with its config file to extend.
enum AppEnvironment {
  development,
  production;

  static const String defineKey = 'APP_ENV';

  /// Resolves the environment from the `APP_ENV` compile-time define.
  ///
  /// Throws an [ArgumentError] when the define is missing or unknown, so a
  /// build never runs against an implicit environment.
  static AppEnvironment fromDefines() =>
      fromName(const String.fromEnvironment(defineKey));

  static AppEnvironment fromName(String name) {
    for (final environment in values) {
      if (environment.name == name) return environment;
    }
    throw ArgumentError.value(
      name,
      defineKey,
      'Expected one of ${values.map((e) => e.name).join(', ')}. '
      'Run with --dart-define-from-file=config/<env>.json',
    );
  }
}
