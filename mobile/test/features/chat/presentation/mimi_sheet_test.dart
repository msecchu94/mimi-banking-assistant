import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mimi/app/theme/app_theme.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/chat_providers.dart';
import 'package:mimi/features/chat/domain/models/chat_reply.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/conversation.dart';
import 'package:mimi/features/chat/domain/models/money.dart';
import 'package:mimi/features/chat/domain/repositories/chat_repository.dart';
import 'package:mimi/features/chat/presentation/conversation/replies/card_list_view.dart';
import 'package:mimi/features/chat/presentation/conversation/replies/expense_comparison_view.dart';
import 'package:mimi/features/chat/presentation/conversation/replies/transaction_list_view.dart';
import 'package:mimi/features/chat/presentation/mimi_sheet/mimi_sheet.dart';
import 'package:mimi/features/home/presentation/home_page.dart';
import 'package:mimi/shared/design_system/components/mimi_button.dart';
import 'package:mimi/shared/design_system/mimi_tokens.dart';

import '../../../helpers/inter_font.dart';

const _conversationId = '9e47b4c1-4a8c-4a3c-98d2-a31c9c87e641';
const _operationId = '5b0c7d2e-3f41-4a6b-9c8d-1e2f3a4b5c6d';
const _cardId = '16e39f21-93b5-48b5-a8dc-90ad03ea5dd1';

const _conversation = Conversation(
  id: _conversationId,
  state: ConversationState.ready,
);

const _card = BankCard(
  id: _cardId,
  brand: CardBrand.visa,
  type: CardType.debit,
  lastFour: '4821',
  status: CardStatus.active,
);

ChatReply _reply(String message, [ChatUi ui = const ChatUi.text()]) =>
    ChatReply(
      conversationId: _conversationId,
      message: message,
      intent: ChatIntent.generalConversation,
      conversationState: ConversationState.ready,
      ui: ui,
    );

Money _ars(String amount) => Money(amount: amount, currency: Currency.ars);

final _expenseSummary = ChatUi.expenseSummary(
  period: ExpensePeriod(
    from: DateTime.utc(2026, 10),
    to: DateTime.utc(2026, 10, 31),
  ),
  currencies: [
    CurrencyExpenses(
      total: _ars('184320.00'),
      categories: [
        CategoryExpense(
          category: TransactionCategory.groceries,
          amount: _ars('184320.00'),
        ),
      ],
    ),
  ],
);

final _confirmation = ChatUi.confirmation(
  operationId: _operationId,
  title: 'Confirmá la transferencia',
  summary: ConfirmationSummary.transfer(
    amount: _ars('25000.00'),
    beneficiary: 'Martín López',
  ),
  actions: const [
    ConfirmationAction(
      type: ConfirmationActionType.confirm,
      label: 'Confirmar',
    ),
    ConfirmationAction(type: ConfirmationActionType.cancel, label: 'Cancelar'),
  ],
);

/// Answers each action with the next queued reply, optionally holding it
/// until [hold] completes, and records every call.
class _ScriptedRepository implements ChatRepository {
  Either<Failure, Conversation> startResult = const Right(_conversation);
  final List<Either<Failure, ChatReply>> replies = [];
  final List<(String, String?)> calls = [];
  Completer<void>? hold;

  Future<Either<Failure, ChatReply>> _next(String method, [String? arg]) async {
    calls.add((method, arg));
    if (hold case final hold?) await hold.future;
    return replies.removeAt(0);
  }

  @override
  Future<Either<Failure, Conversation>> startConversation() async {
    calls.add(('start', null));
    return startResult;
  }

  @override
  Future<Either<Failure, ChatReply>> sendMessage({
    required String conversationId,
    required String message,
  }) => _next('sendMessage', message);

  @override
  Future<Either<Failure, ChatReply>> confirm({
    required String conversationId,
    required String operationId,
  }) => _next('confirm', operationId);

  @override
  Future<Either<Failure, ChatReply>> cancel({required String conversationId}) =>
      _next('cancel');

  @override
  Future<Either<Failure, ChatReply>> selectCard({
    required String conversationId,
    required String cardId,
  }) => _next('selectCard', cardId);

  int count(String method) => calls.where((c) => c.$1 == method).length;
}

const _narrow = Size(320, 568);
const _common = Size(390, 844);

Future<void> _pumpHome(
  WidgetTester tester,
  _ScriptedRepository repository, {
  Size size = _common,
  EdgeInsets safeArea = EdgeInsets.zero,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..padding = FakeViewPadding(top: safeArea.top, bottom: safeArea.bottom);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [chatRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: buildAppTheme(), home: const HomePage()),
    ),
  );
}

Future<void> _openMimi(WidgetTester tester) async {
  await tester.tap(find.text('✦ Mimi'));
  await tester.pumpAndSettle();
}

Future<void> _send(WidgetTester tester, String message) async {
  await tester.enterText(find.byType(TextField), message);
  await tester.pump();
  await tester.tap(find.bySemanticsLabel('Enviar'));
  await tester.pumpAndSettle();
}

double _sheetHeight(WidgetTester tester) =>
    tester.getSize(find.byKey(MimiSheet.surfaceKey)).height;

double _screenHeight(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

bool _isExpanded(WidgetTester tester) =>
    _sheetHeight(tester) > _screenHeight(tester) * 0.9;

void main() {
  setUpAll(loadInterFont);

  testWidgets('opens compact over Home and starts the conversation', (
    tester,
  ) async {
    final repository = _ScriptedRepository();
    await _pumpHome(tester, repository);

    await _openMimi(tester);

    expect(find.text('¿En qué puedo ayudarte hoy?'), findsOneWidget);
    expect(find.text('Preguntale algo a Mimi'), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(_sheetHeight(tester), lessThan(_screenHeight(tester) * 0.75));
    expect(repository.calls, [('start', null)]);
  });

  testWidgets('drags between compact and expanded, then closes', (
    tester,
  ) async {
    await _pumpHome(tester, _ScriptedRepository());
    await _openMimi(tester);

    await tester.drag(
      find.bySemanticsLabel('Expandir Mimi'),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(_isExpanded(tester), isTrue);

    await tester.drag(
      find.bySemanticsLabel('Contraer Mimi'),
      const Offset(0, 600),
    );
    await tester.pumpAndSettle();
    expect(_isExpanded(tester), isFalse);
    expect(find.byType(MimiSheet), findsOneWidget);

    await tester.drag(
      find.bySemanticsLabel('Expandir Mimi'),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MimiSheet), findsNothing);
  });

  testWidgets('tapping the handle toggles the detent', (tester) async {
    await _pumpHome(tester, _ScriptedRepository());
    await _openMimi(tester);

    await tester.tap(find.bySemanticsLabel('Expandir Mimi'));
    await tester.pumpAndSettle();
    expect(_isExpanded(tester), isTrue);

    await tester.tap(find.bySemanticsLabel('Contraer Mimi'));
    await tester.pumpAndSettle();
    expect(_isExpanded(tester), isFalse);
  });

  testWidgets('focusing the composer expands the sheet', (tester) async {
    await _pumpHome(tester, _ScriptedRepository());
    await _openMimi(tester);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(_isExpanded(tester), isTrue);
  });

  testWidgets('shows the message while Mimi answers, then the reply', (
    tester,
  ) async {
    final repository = _ScriptedRepository()
      ..replies.add(Right(_reply(r'Tu saldo es $ 1.284.650,75.')))
      ..hold = Completer();
    await _pumpHome(tester, repository);
    await _openMimi(tester);

    await tester.enterText(find.byType(TextField), '¿Cuál es mi saldo?');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Enviar'));
    await tester.pump();

    expect(find.text('¿Cuál es mi saldo?'), findsOneWidget);
    expect(find.text('Mimi está pensando…'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Otra pregunta');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Enviar'));
    expect(repository.count('sendMessage'), 1, reason: 'one action at a time');

    repository.hold!.complete();
    await tester.pumpAndSettle();

    expect(find.text(r'Tu saldo es $ 1.284.650,75.'), findsOneWidget);
    expect(find.text('Mimi está pensando…'), findsNothing);
    expect(repository.calls.last, ('sendMessage', '¿Cuál es mi saldo?'));
  });

  testWidgets('a failed message returns to the composer, explained', (
    tester,
  ) async {
    final repository = _ScriptedRepository()
      ..replies.add(const Left(ConnectionFailure()));
    await _pumpHome(tester, repository);
    await _openMimi(tester);

    await _send(tester, '¿Cuánto gasté este mes?');

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '¿Cuánto gasté este mes?');
    expect(find.textContaining('No pudimos conectarnos'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('a failed start offers a retry', (tester) async {
    final repository = _ScriptedRepository()
      ..startResult = const Left(ConnectionFailure());
    await _pumpHome(tester, repository);
    await _openMimi(tester);

    expect(find.text('No pudimos iniciar la conversación.'), findsOneWidget);

    repository.startResult = const Right(_conversation);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos iniciar la conversación.'), findsNothing);
    expect(repository.count('start'), 2);
  });

  testWidgets('reopening continues the same conversation', (tester) async {
    final repository = _ScriptedRepository()
      ..replies.add(Right(_reply('¡Hola! ¿En qué te ayudo?')));
    await _pumpHome(tester, repository);
    await _openMimi(tester);
    await _send(tester, 'Hola');

    await tester.drag(
      find.bySemanticsLabel('Contraer Mimi'),
      const Offset(0, 600),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.bySemanticsLabel('Expandir Mimi'),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MimiSheet), findsNothing);

    await _openMimi(tester);

    expect(find.text('¡Hola! ¿En qué te ayudo?'), findsOneWidget);
    expect(repository.count('start'), 1);
  });

  testWidgets('shows the expense summary exactly as the backend sent it', (
    tester,
  ) async {
    final repository = _ScriptedRepository()
      ..replies.add(
        Right(
          _reply(
            r'Este mes gastaste $184.320 en supermercados.',
            _expenseSummary,
          ),
        ),
      );
    await _pumpHome(tester, repository);
    await _openMimi(tester);

    await _send(tester, '¿Cuánto gasté en supermercado este mes?');

    expect(
      find.text(r'Este mes gastaste $184.320 en supermercados.'),
      findsOneWidget,
    );
    expect(find.text('Gastos · 1 – 31 oct 2026'), findsOneWidget);
    expect(find.text(r'$ 184.320,00'), findsNWidgets(2));
    expect(find.text('Supermercado'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('only the latest reply exposes confirmation actions', (
    tester,
  ) async {
    final repository = _ScriptedRepository()
      ..replies.addAll([
        Right(_reply('Revisá la transferencia.', _confirmation)),
        Right(_reply('Listo, la transferencia se realizó.')),
      ]);
    await _pumpHome(tester, repository);
    await _openMimi(tester);
    await _send(tester, r'Transferí $25.000 a Martín');

    expect(find.text('Confirmá la transferencia'), findsOneWidget);
    expect(find.text(r'$ 25.000,00'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(repository.calls.last, ('confirm', _operationId));
    expect(find.text('Confirmá la transferencia'), findsOneWidget);
    expect(find.text('Confirmar'), findsNothing, reason: 'now history');
    expect(find.text('Cancelar'), findsNothing);
  });

  testWidgets('cancel sends the structured CANCEL interaction', (tester) async {
    final repository = _ScriptedRepository()
      ..replies.addAll([
        Right(_reply('Revisá la transferencia.', _confirmation)),
        Right(_reply('Cancelé la operación.')),
      ]);
    await _pumpHome(tester, repository);
    await _openMimi(tester);
    await _send(tester, r'Transferí $25.000 a Martín');

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repository.calls.last, ('cancel', null));
    expect(repository.count('sendMessage'), 1, reason: 'not sent as text');
  });

  testWidgets('the card selector sends the selected card', (tester) async {
    final repository = _ScriptedRepository()
      ..replies.addAll([
        Right(
          _reply(
            '¿Qué tarjeta querés congelar?',
            const ChatUi.cardSelector(cards: [_card]),
          ),
        ),
        Right(_reply('Revisá la operación.')),
      ]);
    await _pumpHome(tester, repository);
    await _openMimi(tester);
    await _send(tester, 'Congelá mi tarjeta');

    await tester.tap(find.text('Visa Débito •••• 4821'));
    await tester.pumpAndSettle();

    expect(repository.calls.last, ('selectCard', _cardId));
    await tester.tap(find.text('Visa Débito •••• 4821'));
    await tester.pumpAndSettle();
    expect(repository.count('selectCard'), 1, reason: 'now history');
  });

  group('card list', () {
    const cards = [
      BankCard(
        id: 'fd4c104d-ea5b-5f30-b9ea-e784c041859d',
        brand: CardBrand.mastercard,
        type: CardType.credit,
        lastFour: '5307',
        status: CardStatus.active,
      ),
      _card,
      BankCard(
        id: '450bd714-6c8f-50c8-9693-70b1a2e3e1a3',
        brand: CardBrand.visa,
        type: CardType.credit,
        lastFour: '9134',
        status: CardStatus.frozen,
      ),
    ];

    Future<_ScriptedRepository> showCards(
      WidgetTester tester,
      List<BankCard> cards, {
      Size size = _common,
    }) async {
      final repository = _ScriptedRepository()
        ..replies.add(
          Right(
            _reply('Encontré tus tarjetas.', ChatUi.cardList(cards: cards)),
          ),
        );
      await _pumpHome(tester, repository, size: size);
      await _openMimi(tester);
      await _send(tester, 'Mostrame mis tarjetas');
      return repository;
    }

    testWidgets('shows each card from the backend under its message', (
      tester,
    ) async {
      await showCards(tester, cards);

      expect(find.text('Encontré tus tarjetas.'), findsOneWidget);
      expect(find.text('Mastercard'), findsOneWidget);
      expect(find.text('Visa'), findsNWidgets(2));
      expect(find.text('Crédito'), findsNWidgets(2));
      expect(find.text('Débito'), findsOneWidget);
      for (final lastFour in ['5307', '4821', '9134']) {
        expect(find.text('•••• $lastFour'), findsOneWidget);
      }
      expect(find.text('Activa'), findsNWidgets(2));
      expect(find.text('Congelada'), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      for (final card in cards) {
        expect(find.textContaining(card.id), findsNothing);
      }
    });

    testWidgets('is display only', (tester) async {
      final repository = await showCards(tester, cards);
      final callsBefore = repository.calls.length;

      for (final label in ['Mastercard', '•••• 5307']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      expect(repository.calls, hasLength(callsBefore));
      expect(find.text('Visa Débito •••• 4821'), findsNothing);
      final controls = find.descendant(
        of: find.byType(CardListView),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is InkResponse ||
              widget is MimiButton ||
              (widget is GestureDetector && widget.onTap != null),
        ),
      );
      expect(controls, findsNothing);
    });

    testWidgets('scrolls horizontally to cards beyond a narrow screen', (
      tester,
    ) async {
      await showCards(tester, cards, size: _narrow);
      expect(tester.takeException(), isNull);
      expect(find.text('•••• 9134').hitTestable(), findsNothing);

      await tester.drag(find.text('•••• 5307'), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('•••• 9134').hitTestable(), findsOneWidget);
    });

    testWidgets('lays out a single card at 320 px', (tester) async {
      await showCards(tester, const [_card], size: _narrow);

      expect(tester.takeException(), isNull);
      expect(find.text('•••• 4821').hitTestable(), findsOneWidget);
      expect(find.text('Activa').hitTestable(), findsOneWidget);
    });
  });

  group('transaction list', () {
    Transaction transaction(
      String id,
      String description,
      String amount,
      TransactionType type,
      TransactionCategory category,
      int day,
    ) => Transaction(
      id: id,
      description: description,
      amount: _ars(amount),
      type: type,
      category: category,
      occurredAt: DateTime.utc(2026, 10, day, 12),
    );

    final transactions = [
      transaction(
        'tx-cafe-0001',
        'Café Plaza Norte',
        '17650.00',
        TransactionType.debit,
        TransactionCategory.dining,
        26,
      ),
      transaction(
        'tx-super-0002',
        'Supermercado La Estancia',
        '52410.70',
        TransactionType.debit,
        TransactionCategory.groceries,
        24,
      ),
      transaction(
        'tx-freelance-0003',
        'Pago freelance — Diseño web',
        '150000.00',
        TransactionType.credit,
        TransactionCategory.other,
        18,
      ),
    ];

    Future<_ScriptedRepository> showTransactions(
      WidgetTester tester,
      List<Transaction> transactions, {
      Size size = _common,
    }) async {
      final repository = _ScriptedRepository()
        ..replies.add(
          Right(
            _reply(
              'Encontré tus movimientos.',
              ChatUi.transactionList(transactions: transactions),
            ),
          ),
        );
      await _pumpHome(tester, repository, size: size);
      await _openMimi(tester);
      await _send(tester, 'Mostrame mis últimos movimientos');
      return repository;
    }

    testWidgets('shows each transaction from the backend under its message', (
      tester,
    ) async {
      await showTransactions(tester, transactions);

      expect(find.text('Encontré tus movimientos.'), findsOneWidget);
      expect(find.text('Café Plaza Norte'), findsOneWidget);
      expect(find.text('Supermercado La Estancia'), findsOneWidget);
      expect(find.text('Pago freelance — Diseño web'), findsOneWidget);
      expect(find.text('Gastronomía'), findsOneWidget);
      expect(find.text('Supermercado'), findsOneWidget);
      expect(find.text('Otros'), findsOneWidget);
      expect(find.text(r'− $ 17.650,00'), findsOneWidget);
      expect(find.text(r'− $ 52.410,70'), findsOneWidget);
      expect(find.text('26 oct'), findsOneWidget);
      expect(find.text('18 oct'), findsOneWidget);
      for (final transaction in transactions) {
        expect(find.textContaining(transaction.id), findsNothing);
      }
    });

    testWidgets('marks a credit as positive, in the positive color', (
      tester,
    ) async {
      await showTransactions(tester, transactions);

      final credit = tester.widget<Text>(find.text(r'+ $ 150.000,00'));
      final debit = tester.widget<Text>(find.text(r'− $ 17.650,00'));
      expect(credit.style?.color, MimiColors.success);
      expect(debit.style?.color, MimiColors.textPrimary);
    });

    testWidgets('is display only', (tester) async {
      final repository = await showTransactions(tester, transactions);
      final callsBefore = repository.calls.length;

      await tester.tap(find.text('Café Plaza Norte'));
      await tester.pumpAndSettle();

      expect(repository.calls, hasLength(callsBefore));
      final controls = find.descendant(
        of: find.byType(TransactionListView),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is InkResponse ||
              widget is MimiButton ||
              (widget is GestureDetector && widget.onTap != null),
        ),
      );
      expect(controls, findsNothing);
    });

    testWidgets('lays out ten long transactions at 320 px', (tester) async {
      final many = [
        for (var day = 1; day <= 10; day++)
          transaction(
            'tx-$day',
            'Delivery — Empanadas La Tucumana, sucursal centro $day',
            '1150000.00',
            day.isEven ? TransactionType.credit : TransactionType.debit,
            TransactionCategory.values[day % TransactionCategory.values.length],
            day,
          ),
      ];
      await showTransactions(tester, many, size: _narrow);

      expect(tester.takeException(), isNull);
      expect(find.byType(TextField).hitTestable(), findsOneWidget);
      expect(find.text(r'+ $ 1.150.000,00'), findsNWidgets(5));
      expect(find.text(r'− $ 1.150.000,00'), findsNWidgets(5));
    });
  });

  group('expense comparison', () {
    final october = ExpensePeriod(
      from: DateTime.utc(2026, 10),
      to: DateTime.utc(2026, 10, 31),
    );
    final september = ExpensePeriod(
      from: DateTime.utc(2026, 9),
      to: DateTime.utc(2026, 9, 30),
    );

    CurrencyComparison comparison(
      String current,
      String previous,
      String difference,
      ExpenseChange change, {
      Currency currency = Currency.ars,
    }) => CurrencyComparison(
      currentTotal: Money(amount: current, currency: currency),
      previousTotal: Money(amount: previous, currency: currency),
      difference: Money(amount: difference, currency: currency),
      change: change,
    );

    Future<_ScriptedRepository> showComparison(
      WidgetTester tester,
      List<CurrencyComparison> currencies, {
      TransactionCategory? category,
      Size size = _common,
    }) async {
      final repository = _ScriptedRepository()
        ..replies.add(
          Right(
            _reply(
              'Respecto del período comparado, gastaste menos.',
              ChatUi.expenseComparison(
                category: category,
                currentPeriod: october,
                previousPeriod: september,
                currencies: currencies,
              ),
            ),
          ),
        );
      await _pumpHome(tester, repository, size: size);
      await _openMimi(tester);
      await _send(tester, 'Compará mis gastos de octubre con septiembre');
      return repository;
    }

    testWidgets('shows a general comparison as the backend sent it', (
      tester,
    ) async {
      await showComparison(tester, [
        comparison(
          '838399.00',
          '930738.25',
          '92339.25',
          ExpenseChange.decrease,
        ),
      ]);

      expect(
        find.text('Respecto del período comparado, gastaste menos.'),
        findsOneWidget,
      );
      expect(find.text('Comparación de gastos'), findsOneWidget);
      expect(find.text('Octubre'), findsOneWidget);
      expect(find.text('Septiembre'), findsOneWidget);
      expect(find.text(r'$ 838.399,00'), findsOneWidget);
      expect(find.text(r'$ 930.738,25'), findsOneWidget);
      expect(find.text(r'$ 92.339,25 menos'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('names the category it was filtered by', (tester) async {
      await showComparison(tester, [
        comparison(
          '291912.00',
          '323251.25',
          '31339.25',
          ExpenseChange.decrease,
        ),
      ], category: TransactionCategory.groceries);

      expect(find.text('Gastos en Supermercado'), findsOneWidget);
      expect(find.text('Comparación de gastos'), findsNothing);
      expect(find.text(r'$ 31.339,25 menos'), findsOneWidget);
    });

    testWidgets('an increase reads as more, in the attention color', (
      tester,
    ) async {
      await showComparison(tester, [
        comparison(
          '185000.00',
          '160000.00',
          '25000.00',
          ExpenseChange.increase,
        ),
      ]);

      final change = tester.widget<Text>(find.text(r'$ 25.000,00 más'));
      expect(change.style?.color, MimiColors.warning);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('no change reads as such, neutrally', (tester) async {
      await showComparison(tester, [
        comparison('0.00', '0.00', '0.00', ExpenseChange.unchanged),
      ]);

      final change = tester.widget<Text>(find.text('Sin cambios'));
      expect(change.style?.color, MimiColors.textSecondary);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the backend direction, not the amounts', (tester) async {
      await showComparison(tester, [
        // Inconsistent on purpose: the direction must come from `change`.
        comparison('100.00', '200.00', '100.00', ExpenseChange.increase),
      ]);

      expect(find.text(r'$ 100,00 más'), findsOneWidget);
    });

    testWidgets('compares each currency on its own', (tester) async {
      await showComparison(tester, [
        comparison(
          '185000.00',
          '160000.00',
          '25000.00',
          ExpenseChange.increase,
        ),
        comparison(
          '80.00',
          '120.00',
          '40.00',
          ExpenseChange.decrease,
          currency: Currency.usd,
        ),
      ], size: _narrow);

      expect(tester.takeException(), isNull);
      expect(find.text(r'$ 25.000,00 más'), findsOneWidget);
      expect(find.text(r'US$ 80,00'), findsOneWidget);
      expect(find.text(r'US$ 120,00'), findsOneWidget);
      expect(find.text(r'US$ 40,00 menos'), findsOneWidget);
      expect(find.text('Octubre'), findsNWidgets(2));
    });

    testWidgets('is display only', (tester) async {
      final repository = await showComparison(tester, [
        comparison(
          '838399.00',
          '930738.25',
          '92339.25',
          ExpenseChange.decrease,
        ),
      ]);
      final callsBefore = repository.calls.length;

      await tester.tap(find.text('Octubre'));
      await tester.pumpAndSettle();

      expect(repository.calls, hasLength(callsBefore));
      final controls = find.descendant(
        of: find.byType(ExpenseComparisonView),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is InkResponse ||
              widget is MimiButton ||
              (widget is GestureDetector && widget.onTap != null),
        ),
      );
      expect(controls, findsNothing);
    });
  });

  testWidgets('other UI types show the backend message only', (tester) async {
    final repository = _ScriptedRepository()
      ..replies.add(
        Right(
          _reply(
            'Encontré un destinatario.',
            const ChatUi.beneficiaryList(
              beneficiaries: [
                Beneficiary(
                  id: 'b-1',
                  name: 'Laura Gómez',
                  accountReference: '****4582',
                  bankName: null,
                ),
              ],
            ),
          ),
        ),
      );
    await _pumpHome(tester, repository);
    await _openMimi(tester);

    await _send(tester, '¿A quién puedo transferir?');

    expect(find.text('Encontré un destinatario.'), findsOneWidget);
    expect(find.text('Laura Gómez'), findsNothing);
  });

  final layouts = {
    '320 px': (_narrow, EdgeInsets.zero),
    '390 px': (_common, EdgeInsets.zero),
    'iPhone 16 Pro': (
      const Size(402, 874),
      const EdgeInsets.only(top: 62, bottom: 34),
    ),
  };
  layouts.forEach((name, layout) {
    testWidgets('lays out compact, expanded and with the keyboard at $name', (
      tester,
    ) async {
      final repository = _ScriptedRepository()
        ..replies.addAll([
          Right(
            _reply(
              r'Este mes gastaste $184.320 en supermercados.',
              _expenseSummary,
            ),
          ),
          Right(_reply('Revisá la transferencia.', _confirmation)),
        ]);
      await _pumpHome(tester, repository, size: layout.$1, safeArea: layout.$2);
      await _openMimi(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField).hitTestable(), findsOneWidget);

      await _send(tester, '¿Cuánto gasté en supermercado este mes?');
      await _send(tester, r'Transferí $25.000 a Martín');
      expect(tester.takeException(), isNull);
      expect(find.text('Confirmar').hitTestable(), findsOneWidget);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField).hitTestable(), findsOneWidget);
      expect(find.text('Confirmar').hitTestable(), findsOneWidget);
    });
  });

  testWidgets('meets tap target and labelling guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    final repository = _ScriptedRepository()
      ..replies.add(Right(_reply('Revisá la transferencia.', _confirmation)));
    await _pumpHome(tester, repository);
    await _openMimi(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await _send(tester, r'Transferí $25.000 a Martín');

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });
}
