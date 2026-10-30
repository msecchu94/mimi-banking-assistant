import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/app/app.dart';
import 'package:mimi/core/config/app_environment.dart';
import 'package:mimi/core/config/app_environment_provider.dart';

void main() {
  testWidgets('boots through the router with the injected environment', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(AppEnvironment.production),
        ],
        child: const MimiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mimi (production)'), findsOneWidget);
  });
}
