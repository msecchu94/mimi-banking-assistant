import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/chat_providers.dart';
import 'package:mimi/features/chat/domain/models/chat_reply.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/conversation.dart';
import 'package:mimi/features/chat/domain/models/money.dart';
import 'package:mimi/features/chat/domain/repositories/chat_repository.dart';
import 'package:mimi/features/chat/presentation/chat_controller.dart';
import 'package:mimi/features/home/home_providers.dart';
import 'package:mimi/features/home/presentation/home_controller.dart';
import 'package:mimi/features/home/presentation/home_view_data.dart';

import '../home_fixtures.dart';

const _conversation = Conversation(id: 'c-1', state: ConversationState.ready);
const _operationId = 'op-1';
final _card = BankCard(
  id: 'card-1',
  brand: CardBrand.visa,
  type: CardType.debit,
  lastFour: '4821',
  status: CardStatus.frozen,
);

ChatReply _reply(ChatUi ui) => ChatReply(
  conversationId: _conversation.id,
  message: 'Listo.',
  intent: ChatIntent.transferMoney,
  conversationState: ConversationState.ready,
  ui: ui,
);

ChatUi _transfer(TransferStatus status) => ChatUi.transferSummary(
  transferId: 'tr-1',
  beneficiary: 'Laura Gómez',
  amount: Money(amount: '1.00', currency: Currency.ars),
  status: status,
  executedAt: DateTime.utc(2026, 11, 9, 16),
);

final _confirmation = ChatUi.confirmation(
  operationId: _operationId,
  title: 'Confirmá la transferencia',
  summary: ConfirmationSummary.transfer(
    amount: Money(amount: '1.00', currency: Currency.ars),
    beneficiary: 'Laura Gómez',
  ),
  actions: const [],
);

/// Answers every chat action with the next queued result.
class _ScriptedChatRepository implements ChatRepository {
  final List<Either<Failure, ChatReply>> results = [];

  Future<Either<Failure, ChatReply>> _next() async => results.removeAt(0);

  @override
  Future<Either<Failure, Conversation>> startConversation() async =>
      const Right(_conversation);

  @override
  Future<Either<Failure, ChatReply>> sendMessage({
    required String conversationId,
    required String message,
  }) => _next();

  @override
  Future<Either<Failure, ChatReply>> confirm({
    required String conversationId,
    required String operationId,
  }) => _next();

  @override
  Future<Either<Failure, ChatReply>> cancel({required String conversationId}) =>
      _next();

  @override
  Future<Either<Failure, ChatReply>> selectCard({
    required String conversationId,
    required String cardId,
  }) => _next();
}

void main() {
  late FakeHomeRepository home;
  late _ScriptedChatRepository chat;
  late ProviderContainer container;

  setUp(() async {
    home = FakeHomeRepository();
    chat = _ScriptedChatRepository();
    container = ProviderContainer(
      overrides: [
        homeRepositoryProvider.overrideWithValue(home),
        chatRepositoryProvider.overrideWithValue(chat),
      ],
    );
    addTearDown(container.dispose);
    // Home is on screen, watching its content.
    container.listen(homeContentProvider, (_, _) {});
    await container.read(chatControllerProvider.notifier).start();
  });

  Future<HomeViewData> content() async =>
      (await container.read(homeContentProvider.future))
          .getOrElse((failure) => fail('Home failed: $failure'));

  ChatController mimi() => container.read(chatControllerProvider.notifier);

  /// The backend's answers once the transfer is persisted.
  void persistTransfer() {
    home
      ..accounts = Right([dollars, savingsAfterTransfer])
      ..transactions = Right(transactionsAfterTransfer());
  }

  test('loads the backend data first', () async {
    final data = await content();

    expect(home.accountRequests, 1);
    expect(data.balance, r'$ 1.284.650,75');
    expect(data.transactions.map((t) => t.id), ['t-1', 't-2', 't-3']);
  });

  test('a confirmed transfer the backend completed reloads Home', () async {
    await content();
    chat.results.addAll([
      Right(_reply(_confirmation)),
      Right(_reply(_transfer(TransferStatus.completed))),
    ]);
    await mimi().sendMessage('Transferí 1 peso a Laura');
    persistTransfer();

    final confirming = mimi().confirm(_operationId);
    expect(home.accountRequests, 1, reason: 'not before the reply arrives');
    await confirming;
    final data = await content();

    expect(home.accountRequests, 2);
    expect(home.transactionRequests, hasLength(2));
    expect(data.balance, r'$ 1.284.649,75');
    expect(data.transactions.map((t) => t.id), ['t-new', 't-1', 't-2']);
  });

  for (final (name, result) in <(String, Either<Failure, ChatReply>)>[
    ('a text reply', Right(_reply(const ChatUi.text()))),
    (
      'transactions',
      Right(_reply(ChatUi.transactionList(transactions: recentTransactions()))),
    ),
    (
      'an expense summary',
      Right(
        _reply(
          ChatUi.expenseSummary(
            period: ExpensePeriod(
              from: DateTime.utc(2026, 11),
              to: DateTime.utc(2026, 11, 9),
            ),
            currencies: const [],
          ),
        ),
      ),
    ),
    ('cards', Right(_reply(ChatUi.cardList(cards: [_card])))),
    (
      'beneficiaries',
      Right(_reply(const ChatUi.beneficiaryList(beneficiaries: []))),
    ),
    ('a confirmation', Right(_reply(_confirmation))),
    ('a failed transfer', Right(_reply(_transfer(TransferStatus.failed)))),
    ('a failure', const Left(ConnectionFailure())),
  ]) {
    test('$name does not reload Home', () async {
      await content();
      chat.results.add(result);

      await mimi().sendMessage('Hola');
      await content();

      expect(home.accountRequests, 1);
    });
  }

  test('a cancelled transfer does not reload Home', () async {
    await content();
    chat.results.addAll([
      Right(_reply(_confirmation)),
      Right(_reply(const ChatUi.text())),
    ]);
    await mimi().sendMessage('Transferí 1 peso a Laura');

    await mimi().cancel();
    await content();

    expect(home.accountRequests, 1);
  });

  test('a failed confirmation does not reload Home', () async {
    await content();
    chat.results.addAll([
      Right(_reply(_confirmation)),
      const Left(
        BackendFailure(
          code: BackendErrorCode.invalidInteraction,
          requestId: 'r-1',
        ),
      ),
    ]);
    await mimi().sendMessage('Transferí 1 peso a Laura');

    await mimi().confirm(_operationId);
    await content();

    expect(home.accountRequests, 1);
  });

  test('a completed card freeze does not reload Home', () async {
    await content();
    chat.results.addAll([
      Right(_reply(_confirmation)),
      Right(_reply(ChatUi.cardList(cards: [_card]))),
    ]);
    await mimi().sendMessage('Congelá mi Visa');

    await mimi().confirm(_operationId);
    await content();

    expect(home.accountRequests, 1);
  });

  test('reloads once per completed transfer, not on later turns', () async {
    await content();
    chat.results.addAll([
      Right(_reply(_transfer(TransferStatus.completed))),
      Right(_reply(const ChatUi.text())),
      const Left(ConnectionFailure()),
    ]);

    await mimi().sendMessage('Transferí 1 peso a Laura');
    await content();
    await mimi().sendMessage('Gracias');
    await mimi().sendMessage('¿Algo más?');
    await mimi().start();
    await content();

    expect(home.accountRequests, 2);
  });
}
