import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/app/theme/app_theme.dart';
import 'package:mimi/features/home/presentation/home_mock_data.dart';
import 'package:mimi/features/home/presentation/home_page.dart';
import 'package:mimi/features/home/presentation/widgets/balance_section.dart';
import 'package:mimi/shared/design_system/components/mimi_card.dart';
import 'package:mimi/shared/design_system/mimi_tokens.dart';

import '../../../helpers/inter_font.dart';

const _data = homeMockData;
const _narrow = Size(320, 568);
const _common = Size(390, 844);

Future<void> _pumpHome(
  WidgetTester tester, {
  Size size = _common,
  double textScale = 1,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    MaterialApp(theme: buildAppTheme(), home: const HomePage()),
  );
}

bool _isTruncated(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).didExceedMaxLines;

void main() {
  setUpAll(loadInterFont);

  testWidgets('shows the DS-04 Home content', (tester) async {
    await _pumpHome(tester);

    for (final text in [
      'Hola, Lucía',
      'Tu caja de ahorro en pesos',
      'Saldo disponible · ARS',
      _data.balance,
      'Transferir',
      'Pagar',
      'Tarjetas',
      _data.account.title,
      _data.account.status,
      'Alias:',
      _data.account.alias,
      'Ver datos',
      'Movimientos',
      'Ver todos',
      for (final transaction in _data.transactions) ...[
        transaction.title,
        transaction.detail,
      ],
      '✦ Mimi',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.bySemanticsLabel('Perfil'), findsOneWidget);
    // Ver datos and Ver todos.
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
  });

  testWidgets('hides and shows the balance', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.bySemanticsLabel('Ocultar saldo'));
    await tester.pump();

    expect(find.text(_data.balance), findsNothing);
    expect(find.text(BalanceSection.hiddenBalance), findsOneWidget);
    expect(find.bySemanticsLabel('Saldo oculto'), findsOneWidget);
    expect(find.text(r'+ $ 85.000,00'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Mostrar saldo'));
    await tester.pump();

    expect(find.text(_data.balance), findsOneWidget);
    expect(find.text(BalanceSection.hiddenBalance), findsNothing);
    expect(find.bySemanticsLabel('Ocultar saldo'), findsOneWidget);
  });

  testWidgets('states transaction direction with a sign, not only color', (
    tester,
  ) async {
    await _pumpHome(tester);

    final credit = tester.widget<Text>(find.text(r'+ $ 85.000,00'));
    expect(credit.style?.color, MimiColors.success);
    expect(find.text(r'− $ 32.480,50'), findsOneWidget);
    expect(find.text(r'− $ 18.900,00'), findsOneWidget);
  });

  testWidgets('marks each transaction with its category icon', (tester) async {
    await _pumpHome(tester);

    for (final (title, icon) in [
      ('Supermercado Día', Icons.shopping_cart_outlined),
      ('Martín López', Icons.swap_horiz),
      ('Personal', Icons.receipt_long_outlined),
    ]) {
      final row = find.ancestor(
        of: find.text(title),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: row.first, matching: find.byIcon(icon)),
        findsOneWidget,
        reason: title,
      );
    }
  });

  testWidgets('shows no account data the summary does not carry', (
    tester,
  ) async {
    await _pumpHome(tester);

    expect(find.textContaining('CBU'), findsNothing);
    expect(find.byIcon(Icons.copy), findsNothing);
    expect(find.byIcon(Icons.copy_outlined), findsNothing);
  });

  testWidgets('groups the transactions in one container', (tester) async {
    await _pumpHome(tester);

    final containers = {
      for (final transaction in _data.transactions)
        tester.element(
          find.ancestor(
            of: find.text(transaction.title),
            matching: find.byType(MimiCard),
          ),
        ),
    };
    expect(containers, hasLength(1));
  });

  for (final size in [_narrow, _common]) {
    testWidgets('keeps the approved typography at ${size.width.toInt()} px', (
      tester,
    ) async {
      await _pumpHome(tester, size: size);

      expect(tester.takeException(), isNull);
      for (final label in [
        'Transferir',
        'Pagar',
        'Tarjetas',
        _data.account.alias,
      ]) {
        expect(_isTruncated(tester, label), isFalse, reason: label);
      }
      final balance = find.text(_data.balance);
      expect(
        tester.getRect(balance).width,
        moreOrLessEquals(tester.getSize(balance).width),
        reason: 'the balance is not scaled down',
      );
    });
  }

  testWidgets('does not overflow at 320 px with large text', (tester) async {
    await _pumpHome(tester, size: _narrow, textScale: 1.3);

    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the last transaction clear of the Mimi FAB', (
    tester,
  ) async {
    await _pumpHome(tester, size: _narrow);

    await tester.drag(find.byType(Scrollable), const Offset(0, -2000));
    await tester.pumpAndSettle();

    expect(find.text(_data.transactions.last.title).hitTestable(), findsOne);
    expect(find.text('✦ Mimi').hitTestable(), findsOne);
  });

  testWidgets('meets tap target and labelling guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpHome(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });
}
