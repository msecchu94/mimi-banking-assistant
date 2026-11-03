import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/core/network/network_exception.dart';
import 'package:mimi/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mimi/features/chat/data/dtos/chat_request_dto.dart';
import 'package:mimi/features/chat/data/dtos/chat_response_dto.dart';
import 'package:mimi/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:mimi/features/chat/domain/models/chat_reply.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/conversation.dart';

import '../../chat_fixtures.dart';

/// Answers with [response] or throws [error], recording each chat request.
class _FakeRemoteDataSource implements ChatRemoteDataSource {
  _FakeRemoteDataSource({this.response, this.error});

  final Map<String, dynamic>? response;
  final Object? error;
  final List<ChatRequestDto> requests = [];

  @override
  Future<ConversationResponseDto> startConversation() async {
    if (error case final error?) throw error;
    return ConversationResponseDto.fromJson(response!);
  }

  @override
  Future<ChatResponseDto> chat(ChatRequestDto request) async {
    requests.add(request);
    if (error case final error?) throw error;
    return ChatResponseDto.fromJson(response!);
  }
}

void main() {
  group('success', () {
    test('starts a conversation', () async {
      final repository = ChatRepositoryImpl(
        _FakeRemoteDataSource(response: conversationResponseJson),
      );

      expect(
        await repository.startConversation(),
        const Right<Failure, Conversation>(
          Conversation(id: conversationId, state: ConversationState.ready),
        ),
      );
    });

    test('sends a message and returns the domain reply', () async {
      final remote = _FakeRemoteDataSource(
        response: chatResponseJson(ui: cardListUiJson, intent: 'GET_CARDS'),
      );

      final result = await ChatRepositoryImpl(remote)
          .sendMessage(conversationId: conversationId, message: 'Mis tarjetas');

      final reply = result.getOrElse((failure) => fail('$failure'));
      expect(reply.intent, ChatIntent.getCards);
      expect(reply.ui, isA<CardListUi>());
      expect(remote.requests.single.toJson(), {
        'conversation_id': conversationId,
        'message': 'Mis tarjetas',
      });
    });

    test(
      'sends structured interactions without converting them to text',
      () async {
        final remote = _FakeRemoteDataSource(response: chatResponseJson());
        final repository = ChatRepositoryImpl(remote);

        await repository.confirm(
          conversationId: conversationId,
          operationId: operationId,
        );
        await repository.cancel(conversationId: conversationId);
        await repository.selectCard(
          conversationId: conversationId,
          cardId: cardId,
        );

        expect(remote.requests.map((r) => r.toJson()), [
          {
            'conversation_id': conversationId,
            'interaction': 'CONFIRM',
            'payload': {'operation_id': operationId},
          },
          {'conversation_id': conversationId, 'interaction': 'CANCEL'},
          {
            'conversation_id': conversationId,
            'interaction': 'SELECT_CARD',
            'payload': {'card_id': cardId},
          },
        ]);
      },
    );
  });

  group('failure', () {
    Future<Either<Failure, ChatReply>> sendWith(_FakeRemoteDataSource remote) =>
        ChatRepositoryImpl(remote)
            .sendMessage(conversationId: conversationId, message: 'x');

    test('a backend error becomes a BackendFailure', () async {
      final result = await sendWith(
        _FakeRemoteDataSource(
          error: const ApiErrorException(
            statusCode: 422,
            code: 'INSUFFICIENT_FUNDS',
            requestId: 'req-1',
          ),
        ),
      );

      expect(
        result,
        const Left<Failure, ChatReply>(
          BackendFailure(
            code: BackendErrorCode.insufficientFunds,
            requestId: 'req-1',
          ),
        ),
      );
    });

    test('a connection error becomes a ConnectionFailure', () async {
      final repository = ChatRepositoryImpl(
        _FakeRemoteDataSource(error: const ConnectionException()),
      );

      expect(
        await repository.startConversation(),
        const Left<Failure, Conversation>(ConnectionFailure()),
      );
    });

    test('a reply outside the contract becomes an UnexpectedFailure', () async {
      final result = await sendWith(
        _FakeRemoteDataSource(
          response: chatResponseJson(intent: 'OPEN_ACCOUNT'),
        ),
      );

      expect(result, const Left<Failure, ChatReply>(UnexpectedFailure()));
    });

    test('programming errors are not disguised as failures', () async {
      await expectLater(
        sendWith(_FakeRemoteDataSource(error: StateError('bug'))),
        throwsStateError,
      );
    });
  });
}
