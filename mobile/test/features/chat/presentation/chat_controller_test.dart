import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/chat_providers.dart';
import 'package:mimi/features/chat/domain/models/chat_reply.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/conversation.dart';
import 'package:mimi/features/chat/domain/usecases/cancel_interaction.dart';
import 'package:mimi/features/chat/domain/usecases/confirm_interaction.dart';
import 'package:mimi/features/chat/domain/usecases/select_card.dart';
import 'package:mimi/features/chat/domain/usecases/send_message.dart';
import 'package:mimi/features/chat/domain/usecases/start_conversation.dart';
import 'package:mimi/features/chat/presentation/chat_controller.dart';
import 'package:mimi/features/chat/presentation/chat_state.dart';

const _conversationId = '9e47b4c1-4a8c-4a3c-98d2-a31c9c87e641';
const _operationId = '5b0c7d2e-3f41-4a6b-9c8d-1e2f3a4b5c6d';
const _cardId = '16e39f21-93b5-48b5-a8dc-90ad03ea5dd1';

const _conversation = Conversation(
  id: _conversationId,
  state: ConversationState.ready,
);

ChatReply _reply(String message, [ConversationState? state]) => ChatReply(
  conversationId: _conversationId,
  message: message,
  intent: ChatIntent.generalConversation,
  conversationState: state ?? ConversationState.ready,
  ui: const ChatUi.text(),
);

const _failure = BackendFailure(
  code: BackendErrorCode.conversationNotFound,
  requestId: 'req-1',
);

const _startFailed = Left<Failure, Conversation>(_failure);
const _actionFailed = Left<Failure, ChatReply>(_failure);

/// A use-case result the test releases with [complete], recording the
/// arguments of each call.
class _Gate<T> {
  final List<Map<String, String>> calls = [];
  Completer<Either<Failure, T>>? _pending;

  Future<Either<Failure, T>> invoke([
    Map<String, String> arguments = const {},
  ]) {
    calls.add(arguments);
    return (_pending = Completer()).future;
  }

  void complete(Either<Failure, T> result) => _pending!.complete(result);
}

class _FakeStartConversation implements StartConversation {
  _FakeStartConversation(this._gate);
  final _Gate<Conversation> _gate;

  @override
  Future<Either<Failure, Conversation>> call() => _gate.invoke();
}

class _FakeSendMessage implements SendMessage {
  _FakeSendMessage(this._gate);
  final _Gate<ChatReply> _gate;

  @override
  Future<Either<Failure, ChatReply>> call({
    required String conversationId,
    required String message,
  }) => _gate.invoke({'conversationId': conversationId, 'message': message});
}

class _FakeConfirmInteraction implements ConfirmInteraction {
  _FakeConfirmInteraction(this._gate);
  final _Gate<ChatReply> _gate;

  @override
  Future<Either<Failure, ChatReply>> call({
    required String conversationId,
    required String operationId,
  }) => _gate.invoke({
    'conversationId': conversationId,
    'operationId': operationId,
  });
}

class _FakeCancelInteraction implements CancelInteraction {
  _FakeCancelInteraction(this._gate);
  final _Gate<ChatReply> _gate;

  @override
  Future<Either<Failure, ChatReply>> call({required String conversationId}) =>
      _gate.invoke({'conversationId': conversationId});
}

class _FakeSelectCard implements SelectCard {
  _FakeSelectCard(this._gate);
  final _Gate<ChatReply> _gate;

  @override
  Future<Either<Failure, ChatReply>> call({
    required String conversationId,
    required String cardId,
  }) => _gate.invoke({'conversationId': conversationId, 'cardId': cardId});
}

void main() {
  late _Gate<Conversation> start;
  late _Gate<ChatReply> send;
  late _Gate<ChatReply> confirm;
  late _Gate<ChatReply> cancel;
  late _Gate<ChatReply> select;
  late ProviderContainer container;

  ChatController controller() =>
      container.read(chatControllerProvider.notifier);
  ChatState state() => container.read(chatControllerProvider);
  ChatActive active() => state() as ChatActive;

  /// Runs [operation] and releases [gate] with [result].
  Future<void> settle<T>(
    Future<void> operation,
    _Gate<T> gate,
    Either<Failure, T> result,
  ) {
    gate.complete(result);
    return operation;
  }

  Future<void> startConversation() =>
      settle(controller().start(), start, const Right(_conversation));

  setUp(() {
    start = _Gate();
    send = _Gate();
    confirm = _Gate();
    cancel = _Gate();
    select = _Gate();
    container = ProviderContainer(
      overrides: [
        startConversationProvider.overrideWithValue(
          _FakeStartConversation(start),
        ),
        sendMessageProvider.overrideWithValue(_FakeSendMessage(send)),
        confirmInteractionProvider.overrideWithValue(
          _FakeConfirmInteraction(confirm),
        ),
        cancelInteractionProvider.overrideWithValue(
          _FakeCancelInteraction(cancel),
        ),
        selectCardProvider.overrideWithValue(_FakeSelectCard(select)),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('starts in the initial state without calling any use case', () {
    expect(state(), const ChatState.initial());
    expect(start.calls, isEmpty);
  });

  group('start', () {
    test('is in progress, then active with an empty transcript', () async {
      final operation = controller().start();
      expect(state(), const ChatState.starting());

      await settle(operation, start, const Right(_conversation));

      expect(
        state(),
        const ChatState.active(conversation: _conversation, transcript: []),
      );
      expect(active().flowState, ConversationState.ready);
      expect(active().latestReply, isNull);
    });

    test('exposes a failure, and can be started again', () async {
      await settle(controller().start(), start, _startFailed);
      expect(state(), const ChatState.startFailed(_failure));

      await startConversation();
      expect(state(), isA<ChatActive>());
      expect(start.calls, hasLength(2));
    });

    test('ignores a second start while one is in progress', () async {
      final operation = controller().start();
      await controller().start();

      await settle(operation, start, const Right(_conversation));
      expect(start.calls, hasLength(1));
    });

    test('explicitly replaces an active conversation', () async {
      await startConversation();
      await settle(controller().sendMessage('Hola'), send, Right(_reply('a')));

      const next = Conversation(id: 'other', state: ConversationState.ready);
      await settle(controller().start(), start, const Right(next));

      expect(
        state(),
        const ChatState.active(conversation: next, transcript: []),
      );
    });
  });

  group('actions on an active conversation', () {
    setUp(() => startConversation());

    test(
      'sendMessage is pending, then adds the message and the reply',
      () async {
        final reply = _reply('Tu saldo es 100.00 ARS.');
        final operation = controller().sendMessage('¿Cuánta plata tengo?');

        expect(
          active().pendingAction,
          const ChatAction.sendMessage('¿Cuánta plata tengo?'),
        );
        expect(active().transcript, isEmpty);

        await settle(operation, send, Right(reply));

        expect(send.calls.single, {
          'conversationId': _conversationId,
          'message': '¿Cuánta plata tengo?',
        });
        expect(active().transcript, [
          const ChatEntry.userMessage('¿Cuánta plata tengo?'),
          ChatEntry.assistantReply(reply),
        ]);
        expect(active().pendingAction, isNull);
        expect(active().lastFailure, isNull);
      },
    );

    test('confirm passes the operation id and adds only the reply', () async {
      final operation = controller().confirm(_operationId);
      expect(active().pendingAction, const ChatAction.confirm(_operationId));

      await settle(operation, confirm, Right(_reply('Listo')));

      expect(confirm.calls.single, {
        'conversationId': _conversationId,
        'operationId': _operationId,
      });
      expect(active().transcript, [ChatEntry.assistantReply(_reply('Listo'))]);
    });

    test('cancel passes the conversation and adds only the reply', () async {
      final operation = controller().cancel();
      expect(active().pendingAction, const ChatAction.cancel());

      await settle(operation, cancel, Right(_reply('Cancelado')));

      expect(cancel.calls.single, {'conversationId': _conversationId});
      expect(active().transcript, [
        ChatEntry.assistantReply(_reply('Cancelado')),
      ]);
    });

    test('selectCard passes the card id and adds only the reply', () async {
      final operation = controller().selectCard(_cardId);
      expect(active().pendingAction, const ChatAction.selectCard(_cardId));

      await settle(operation, select, Right(_reply('¿Confirmás?')));

      expect(select.calls.single, {
        'conversationId': _conversationId,
        'cardId': _cardId,
      });
      expect(active().transcript, [
        ChatEntry.assistantReply(_reply('¿Confirmás?')),
      ]);
    });

    test('flowState and latestReply follow the latest reply', () async {
      final waiting = _reply(
        '¿Confirmás?',
        ConversationState.waitingConfirmation,
      );
      await settle(controller().sendMessage('Transferí'), send, Right(waiting));

      expect(active().latestReply, waiting);
      expect(active().flowState, ConversationState.waitingConfirmation);
    });

    test('a failure keeps the conversation and transcript', () async {
      final first = _reply('Hola');
      await settle(controller().sendMessage('Hola'), send, Right(first));
      final before = active();

      await settle(controller().confirm(_operationId), confirm, _actionFailed);

      expect(active().conversation, before.conversation);
      expect(active().transcript, before.transcript);
      expect(active().pendingAction, isNull);
      expect(
        active().lastFailure,
        const ChatActionFailure(
          action: ChatAction.confirm(_operationId),
          failure: _failure,
        ),
      );
    });

    test('a failed message is not added and stays recoverable', () async {
      await settle(controller().sendMessage('Hola'), send, _actionFailed);

      expect(active().transcript, isEmpty);
      expect(
        active().lastFailure?.action,
        const ChatAction.sendMessage('Hola'),
      );
    });

    test('the next action clears the previous failure', () async {
      await settle(controller().cancel(), cancel, _actionFailed);

      final operation = controller().sendMessage('Hola');
      expect(active().lastFailure, isNull);

      await settle(operation, send, Right(_reply('Hola')));
      expect(active().lastFailure, isNull);
    });

    test('ignores actions while another one is in progress', () async {
      final operation = controller().confirm(_operationId);

      await controller().confirm(_operationId);
      await controller().sendMessage('Hola');
      await controller().cancel();
      await controller().selectCard(_cardId);
      await controller().start();

      await settle(operation, confirm, Right(_reply('Listo')));
      expect(confirm.calls, hasLength(1));
      expect(send.calls, isEmpty);
      expect(cancel.calls, isEmpty);
      expect(select.calls, isEmpty);
      expect(start.calls, hasLength(1));
    });

    test('a disposed controller ignores a late result', () async {
      final operation = controller().sendMessage('Hola');
      container.dispose();

      await expectLater(
        settle(operation, send, Right(_reply('Hola'))),
        completes,
      );
      container = ProviderContainer();
    });
  });

  test('ignores actions without an active conversation', () async {
    await controller().sendMessage('Hola');
    await controller().confirm(_operationId);
    await controller().cancel();
    await controller().selectCard(_cardId);

    final starting = controller().start();
    await controller().sendMessage('Hola');
    await settle(starting, start, _startFailed);
    await controller().sendMessage('Hola');

    expect(send.calls, isEmpty);
    expect(confirm.calls, isEmpty);
    expect(cancel.calls, isEmpty);
    expect(select.calls, isEmpty);
    expect(state(), const ChatState.startFailed(_failure));
  });
}
