import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/api_base_url.dart';
import 'core/config/api_base_url_provider.dart';
import 'core/config/app_environment.dart';
import 'core/config/app_environment_provider.dart';

/// Composition root: resolves configuration and wires dependencies.
void main() {
  final environment = AppEnvironment.fromDefines();
  final apiBaseUrl = ApiBaseUrl.fromDefines();

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(environment),
        apiBaseUrlProvider.overrideWithValue(apiBaseUrl),
      ],
      child: const MimiApp(),
    ),
  );
}
