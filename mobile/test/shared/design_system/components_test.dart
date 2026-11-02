import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/shared/design_system/components/mimi_button.dart';
import 'package:mimi/shared/design_system/components/mimi_composer.dart';
import 'package:mimi/shared/design_system/components/mimi_fab.dart';
import 'package:mimi/shared/design_system/components/mimi_icon_button.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  for (final variant in MimiButtonVariant.values) {
    testWidgets('${variant.name} MimiButton is a 48 px tappable label', (
      tester,
    ) async {
      var taps = 0;
      await _pump(
        tester,
        MimiButton(label: 'Pagar', variant: variant, onPressed: () => taps++),
      );

      await tester.tap(find.text('Pagar'));

      expect(taps, 1);
      expect(tester.getSize(find.byType(MimiButton)).height, 48);
    });
  }

  testWidgets('MimiButton shows an optional icon with its label', (
    tester,
  ) async {
    await _pump(
      tester,
      MimiButton(label: 'Pagar', icon: Icons.qr_code_scanner, onPressed: () {}),
    );

    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(find.bySemanticsLabel('Pagar'), findsOneWidget);
    expect(
      tester.getSize(find.byType(MimiButton)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('MimiIconButton exposes its label and a 48 px target', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      MimiIconButton(
        icon: Icons.person_outline,
        semanticLabel: 'Perfil',
        onPressed: () => taps++,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Perfil'));

    expect(taps, 1);
    expect(tester.getSize(find.byType(MimiIconButton)), const Size.square(48));
  });

  testWidgets('MimiFab keeps the visible Mimi name', (tester) async {
    var taps = 0;
    await _pump(tester, MimiFab(onPressed: () => taps++));

    await tester.tap(find.text('✦ Mimi'));

    expect(taps, 1);
    expect(tester.getSize(find.byType(MimiFab)).height, 48);
  });

  group('MimiComposer', () {
    Future<List<String>> pumpComposer(
      WidgetTester tester,
      TextEditingController controller, {
      bool canSend = true,
    }) async {
      final sent = <String>[];
      await _pump(
        tester,
        MimiComposer(
          controller: controller,
          canSend: canSend,
          onSend: sent.add,
        ),
      );
      return sent;
    }

    testWidgets('sends the trimmed text only when there is some', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final sent = await pumpComposer(tester, controller);

      await tester.tap(find.bySemanticsLabel('Enviar'));
      expect(sent, isEmpty);

      await tester.enterText(find.byType(TextField), '  Hola Mimi  ');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Enviar'));

      expect(sent, ['Hola Mimi']);
    });

    testWidgets('does not send while sending is unavailable', (tester) async {
      final controller = TextEditingController(text: 'Hola');
      addTearDown(controller.dispose);
      final sent = await pumpComposer(tester, controller, canSend: false);

      await tester.tap(find.bySemanticsLabel('Enviar'));

      expect(sent, isEmpty);
    });

    testWidgets('keeps a 48 px send target', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpComposer(tester, controller);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });
  });
}
