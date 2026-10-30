import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mimi/core/config/app_environment.dart';
import 'package:mimi/main.dart' as app;

/// Run with:
/// flutter test integration_test --dart-define-from-file=config/development.json
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches from the composition root', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final environment = AppEnvironment.fromDefines();
    expect(find.text('Mimi (${environment.name})'), findsOneWidget);
  });
}
