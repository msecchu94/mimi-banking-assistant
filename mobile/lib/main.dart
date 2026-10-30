import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_environment.dart';
import 'core/config/app_environment_provider.dart';

/// Composition root: resolves configuration and wires dependencies.
void main() {
  final environment = AppEnvironment.fromDefines();

  runApp(
    ProviderScope(
      overrides: [appEnvironmentProvider.overrideWithValue(environment)],
      child: const MimiApp(),
    ),
  );
}
