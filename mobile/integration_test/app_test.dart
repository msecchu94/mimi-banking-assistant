import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mimi/features/home/presentation/home_page.dart';
import 'package:mimi/main.dart' as app;

/// Run with:
/// flutter test integration_test --dart-define-from-file=config/development.json
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches from the composition root into Home', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}
