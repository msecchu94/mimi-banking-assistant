import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mimi/app/theme/app_theme.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/home/domain/models/account.dart';
import 'package:mimi/features/home/domain/models/home_summary.dart';
import 'package:mimi/features/home/home_providers.dart';
import 'package:mimi/features/home/presentation/home_controller.dart';
import 'package:mimi/features/home/presentation/home_page.dart';
import 'package:mimi/features/home/presentation/home_view_data.dart';
import 'package:mimi/features/home/presentation/widgets/balance_section.dart';
import 'package:mimi/features/home/presentation/widgets/recent_transactions.dart';
import 'package:mimi/shared/design_system/components/mimi_card.dart';
import 'package:mimi/shared/design_system/mimi_tokens.dart';

import '../../../helpers/inter_font.dart';
import '../home_fixtures.dart';

final _data = homeViewDataFrom(
  HomeSummary(account: savings, recentTransactions: recentTransactions()),
  now: DateTime.now(),
);
const _narrow = Size(320, 568);
const _common = Size(390, 844);

/// Holds the accounts request open until [complete] is called.
class _PendingHomeRepository extends FakeHomeRepository {
  final _accounts = Completer<Either<Failure, List<Account>>>();

  void complete() => _accounts.complete(Right([savings]));

  @override
  Future<Either<Failure, List<Account>>> getAccounts() {
    accountRequests++;
    return _accounts.future;
  }
}

Future<void> _pumpHome(
  WidgetTester tester, {
  Size size = _common,
  double textScale = 1,
  FakeHomeRepository? repository,
  bool settle = true,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeRepositoryProvider.overrideWithValue(
          repository ?? FakeHomeRepository(),
        ),
      ],
      child: MaterialApp(theme: buildAppTheme(), home: const HomePage()),
    ),
  );
  if (settle) await tester.pump();
}

bool _isTruncated(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).didExceedMaxLines;

/// Reloads Home's content, as a completed transfer or a retry does.
void _refresh(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(HomePage)))
        .invalidate(homeContentProvider);

/// The transaction titles shown, top to bottom.
List<String> _shownTitles(WidgetTester tester, List<String> candidates) {
  final shown = [
    for (final title in candidates)
      if (find.text(title).evaluate().isNotEmpty) title,
  ];
  return shown..sort(
    (a, b) => tester
        .getTopLeft(find.text(a))
        .dy
        .compareTo(tester.getTopLeft(find.text(b)).dy),
  );
}

const _loading = 'Cargando tu cuenta';

void main() {
  setUpAll(loadInterFont);

  testWidgets('shows the DS-04 Home content from the backend', (tester) async {
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

  testWidgets('shows a loading state until the account arrives', (
    tester,
  ) async {
    final repository = _PendingHomeRepository();
    await _pumpHome(tester, repository: repository, settle: false);
    await tester.pump();

    expect(find.bySemanticsLabel('Cargando tu cuenta'), findsOneWidget);
    expect(find.text('Hola, Lucía'), findsOneWidget);
    expect(find.text(_data.balance), findsNothing);
    expect(find.text('✦ Mimi'), findsOneWidget);

    repository.complete();
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel('Cargando tu cuenta'), findsNothing);
    expect(find.text(_data.balance), findsOneWidget);
  });

  testWidgets('shows a failure with a retry that reloads the account', (
    tester,
  ) async {
    final repository = FakeHomeRepository(
      accounts: const Left(ConnectionFailure()),
    );
    await _pumpHome(tester, repository: repository);

    expect(
      find.text(
        'No pudimos conectarnos. Revisá tu conexión e intentá de nuevo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Movimientos'), findsNothing);
    expect(find.text('✦ Mimi'), findsOneWidget);

    repository.accounts = Right([savings]);
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump();

    expect(repository.accountRequests, 2);
    expect(find.text('Reintentar'), findsNothing);
    expect(find.text(_data.balance), findsOneWidget);
  });

  testWidgets('explains a missing ARS account', (tester) async {
    await _pumpHome(
      tester,
      repository: FakeHomeRepository(accounts: Right([dollars])),
    );

    expect(
      find.text('No pudimos cargar tu cuenta. Intentá de nuevo.'),
      findsOneWidget,
    );
  });

  testWidgets('says when the account has no transactions', (tester) async {
    await _pumpHome(
      tester,
      repository: FakeHomeRepository(
        transactions: const Right(<Transaction>[]),
      ),
    );

    expect(find.text('Movimientos'), findsOneWidget);
    expect(find.text('Todavía no tenés movimientos.'), findsOneWidget);
  });

  group('refresh', () {
    const before = r'$ 1.284.650,75';
    const after = r'$ 1.284.649,75';
    const titles = [
      'Transferencia a Laura Gómez',
      'Supermercado Día',
      'Martín López',
      'Personal',
    ];

    testWidgets('keeps Home while it reloads, then shows the new data', (
      tester,
    ) async {
      final repository = GatedHomeRepository();
      await _pumpHome(tester, repository: repository);
      expect(_shownTitles(tester, titles), titles.sublist(1));
      final retainedTop = tester.getTopLeft(find.text('Supermercado Día')).dy;

      repository
        ..accounts = Right([savingsAfterTransfer])
        ..transactions = Right(transactionsAfterTransfer())
        ..gate = Completer();
      _refresh(tester);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(repository.accountRequests, 2);
      expect(find.bySemanticsLabel(_loading), findsNothing);
      expect(find.text(before), findsOneWidget, reason: 'not changed locally');
      expect(find.text(after), findsNothing);
      expect(_shownTitles(tester, titles), titles.sublist(1));

      repository.gate!.complete();
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue, reason: 'transitions');
      expect(find.bySemanticsLabel(_loading), findsNothing);

      // Midway, the new row is entering while the dropped one exits.
      await tester.pump(RecentTransactions.transition ~/ 2);
      expect(find.text(titles.first), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text(after), findsOneWidget);
      expect(find.text(before), findsNothing);
      expect(_shownTitles(tester, titles), titles.sublist(0, 3));
      expect(find.text('Personal'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Supermercado Día')).dy,
        greaterThan(retainedTop),
        reason: 'retained rows move below the new one',
      );
      expect(
        find.descendant(
          of: find.byType(RecentTransactions),
          matching: find.byType(Divider),
        ),
        findsNWidgets(2),
        reason: 'three rows',
      );
    });

    testWidgets('an unchanged reload animates nothing', (tester) async {
      final repository = FakeHomeRepository();
      await _pumpHome(tester, repository: repository);

      _refresh(tester);
      await tester.pump();
      await tester.pump();

      expect(repository.accountRequests, 2);
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text(before), findsOneWidget);
      expect(_shownTitles(tester, titles), titles.sublist(1));
    });

    testWidgets('a retry after a failure still shows the loading state', (
      tester,
    ) async {
      final repository = GatedHomeRepository()
        ..accounts = const Left(ConnectionFailure());
      await _pumpHome(tester, repository: repository);

      repository
        ..accounts = Right([savings])
        ..gate = Completer();
      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(find.bySemanticsLabel(_loading), findsOneWidget);
      expect(find.text('Reintentar'), findsNothing);

      repository.gate!.complete();
      await tester.pump();
      await tester.pump();

      expect(find.bySemanticsLabel(_loading), findsNothing);
      expect(find.text(before), findsOneWidget);
    });
  });
}
