import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/app/app.dart';
import 'package:mimi/features/home/presentation/home_page.dart';

void main() {
  testWidgets('boots through the router into Home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MimiApp()));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}
