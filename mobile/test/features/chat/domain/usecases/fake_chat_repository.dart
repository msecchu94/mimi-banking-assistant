import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/domain/models/chat_reply.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/conversation.dart';
import 'package:mimi/features/chat/domain/repositories/chat_repository.dart';

const conversationId = '9e47b4c1-4a8c-4a3c-98d2-a31c9c87e641';

const conversation = Conversation(
  id: conversationId,
  state: ConversationState.ready,
);

const reply = ChatReply(
  conversationId: conversationId,
  message: 'Hola',
  intent: ChatIntent.generalConversation,
  conversationState: ConversationState.ready,
  ui: ChatUi.text(),
);

/// One failure of each kind a repository can return.
final failures = <Failure>[
  BackendFailure(code: BackendErrorCode.invalidInteraction, requestId: 'r-1'),
  ConnectionFailure(),
  UnexpectedFailure(),
];

/// A repository call: the method name and the arguments it received.
typedef RepositoryCall = ({String method, Map<String, String> arguments});

/// Answers every call with [failure] when given, otherwise with [conversation]
/// or [reply], recording each call.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository({this.failure});

  final Failure? failure;
  final List<RepositoryCall> calls = [];

  Future<Either<Failure, T>> _answer<T>(
    T value,
    String method, [
    Map<String, String> arguments = const {},
  ]) async {
    calls.add((method: method, arguments: arguments));
    final failure = this.failure;
    return failure == null ? Right(value) : Left(failure);
  }

  @override
  Future<Either<Failure, Conversation>> startConversation() =>
      _answer(conversation, 'startConversation');

  @override
  Future<Either<Failure, ChatReply>> sendMessage({
    required String conversationId,
    required String message,
  }) => _answer(reply, 'sendMessage', {
    'conversationId': conversationId,
    'message': message,
  });

  @override
  Future<Either<Failure, ChatReply>> confirm({
    required String conversationId,
    required String operationId,
  }) => _answer(reply, 'confirm', {
    'conversationId': conversationId,
    'operationId': operationId,
  });

  @override
  Future<Either<Failure, ChatReply>> cancel({required String conversationId}) =>
      _answer(reply, 'cancel', {'conversationId': conversationId});

  @override
  Future<Either<Failure, ChatReply>> selectCard({
    required String conversationId,
    required String cardId,
  }) => _answer(reply, 'selectCard', {
    'conversationId': conversationId,
    'cardId': cardId,
  });
}

/// Checks that [run] returns the repository's result unchanged, propagates
/// each [failures] instance as is, and makes exactly the [expected] call.
void verifyUseCase<T>({
  required Future<Either<Failure, T>> Function(ChatRepository repository) run,
  required T value,
  required RepositoryCall expected,
}) {
  test('returns the repository result unchanged', () async {
    final repository = FakeChatRepository();

    final result = await run(repository);

    expect(result, Right<Failure, T>(value));
  });

  test('propagates each failure without remapping it', () async {
    for (final failure in failures) {
      final result = await run(FakeChatRepository(failure: failure));

      expect(result.getLeft().toNullable(), same(failure), reason: '$failure');
    }
  });

  test(
    'calls only ${expected.method}, once, with the given arguments',
    () async {
      final repository = FakeChatRepository();

      await run(repository);

      expect(repository.calls, hasLength(1));
      expect(repository.calls.single.method, expected.method);
      expect(repository.calls.single.arguments, expected.arguments);
    },
  );
}
