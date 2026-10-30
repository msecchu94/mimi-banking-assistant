import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_environment.dart';

part 'app_environment_provider.g.dart';

/// The environment resolved at bootstrap.
///
/// Must be overridden at the composition root (`main.dart`) or in tests.
@Riverpod(keepAlive: true)
AppEnvironment appEnvironment(Ref ref) =>
    throw StateError('appEnvironmentProvider must be overridden at bootstrap');
