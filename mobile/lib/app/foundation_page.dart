import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_environment_provider.dart';

/// Temporary, neutral initial route so the app is runnable.
///
/// Replace it when the first feature route is introduced.
@RoutePage()
class FoundationPage extends ConsumerWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(appEnvironmentProvider);

    return Scaffold(body: Center(child: Text('Mimi (${environment.name})')));
  }
}
