import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/network/network_exception.dart';
import 'package:mimi/features/chat/data/datasources/chat_api_client.dart';
import 'package:mimi/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mimi/features/chat/data/dtos/chat_request_dto.dart';
import 'package:mimi/features/chat/data/dtos/chat_response_dto.dart';

import '../../../../helpers/fake_http_client_adapter.dart';
import '../../chat_fixtures.dart';

const _message = MessageRequestDto(
  conversationId: conversationId,
  message: 'What is my balance?',
);

void main() {
  late FakeHttpClientAdapter adapter;

  ChatRemoteDataSource dataSource() => ChatRemoteDataSource(
    ChatApiClient(
      Dio(BaseOptions(baseUrl: 'http://localhost:8000'))
        ..httpClientAdapter = adapter,
    ),
  );

  group('success', () {
    test('starts a conversation with POST /conversations', () async {
      adapter = FakeHttpClientAdapter.json(201, conversationResponseJson);

      final dto = await dataSource().startConversation();

      expect(dto.conversationId, conversationId);
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri, Uri.parse('http://localhost:8000/conversations'));
      expect(request.data, isNull);
    });

    test('sends a chat request as JSON to POST /chat', () async {
      adapter = FakeHttpClientAdapter.json(
        200,
        chatResponseJson(ui: transferConfirmationUiJson),
      );

      final dto = await dataSource().chat(_message);

      expect(dto.ui, isA<ConfirmationUiDto>());
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri, Uri.parse('http://localhost:8000/chat'));
      expect(request.data, _message.toJson());
    });
  });

  group('failure', () {
    test('a contract error response becomes an ApiErrorException', () async {
      adapter = FakeHttpClientAdapter.json(404, apiErrorJson);

      await expectLater(
        dataSource().chat(_message),
        throwsA(
          isA<ApiErrorException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.code, 'code', 'CONVERSATION_NOT_FOUND')
              .having((e) => e.requestId, 'requestId', 'req-91af23c1'),
        ),
      );
    });

    test('a non-contract error body becomes an invalid response', () async {
      for (final makeAdapter in [
        () => FakeHttpClientAdapter.json(405, {'detail': 'Method Not Allowed'}),
        () => FakeHttpClientAdapter.text(502, '<html>Bad Gateway</html>'),
      ]) {
        adapter = makeAdapter();

        await expectLater(
          dataSource().chat(_message),
          throwsA(isA<InvalidResponseException>()),
        );
      }
    });

    test(
      'a success body outside the contract becomes an invalid response',
      () async {
        for (final body in <Object?>[
          chatResponseJson(ui: {'type': 'ERROR', 'data': <String, dynamic>{}}),
          <Object>[],
          null,
        ]) {
          adapter = FakeHttpClientAdapter.json(200, body);

          await expectLater(
            dataSource().chat(_message),
            throwsA(isA<InvalidResponseException>()),
            reason: '$body',
          );
        }
      },
    );

    test('an unreachable backend becomes a ConnectionException', () async {
      adapter = FakeHttpClientAdapter.failing(
        (options) => DioException.connectionError(
          requestOptions: options,
          reason: 'Connection refused',
        ),
      );

      await expectLater(
        dataSource().startConversation(),
        throwsA(isA<ConnectionException>()),
      );
    });

    test('a timeout becomes a ConnectionException', () async {
      adapter = FakeHttpClientAdapter.failing(
        (options) => DioException.receiveTimeout(
          timeout: const Duration(seconds: 30),
          requestOptions: options,
        ),
      );

      await expectLater(
        dataSource().chat(_message),
        throwsA(isA<ConnectionException>()),
      );
    });
  });
}
