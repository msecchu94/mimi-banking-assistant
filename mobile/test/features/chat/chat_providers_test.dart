import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/config/api_base_url_provider.dart';
import 'package:mimi/core/network/dio_provider.dart';
import 'package:mimi/core/network/http_logging_interceptor.dart';
import 'package:mimi/features/chat/chat_providers.dart';
import 'package:mimi/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';

import '../../helpers/fake_http_client_adapter.dart';
import 'chat_fixtures.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        apiBaseUrlProvider.overrideWithValue(
          Uri.parse('http://localhost:8000'),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('binds ChatRepository to ChatRepositoryImpl', () {
    expect(container.read(chatRepositoryProvider), isA<ChatRepositoryImpl>());
  });

  test('configures Dio from the base URL with the interceptor', () {
    final dio = container.read(dioProvider);

    expect(dio.options.baseUrl, 'http://localhost:8000');
    expect(dio.options.contentType, Headers.jsonContentType);
    expect(dio.interceptors.whereType<HttpLoggingInterceptor>(), hasLength(1));
  });

  test('the repository reaches the backend through the wired Dio', () async {
    final adapter = FakeHttpClientAdapter.json(
      200,
      chatResponseJson(ui: transferSummaryUiJson),
    );
    container.read(dioProvider).httpClientAdapter = adapter;

    final result = await container
        .read(chatRepositoryProvider)
        .sendMessage(conversationId: conversationId, message: 'Hola');

    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((failure) => fail('$failure')).ui,
      isA<TransferSummaryUi>(),
    );
    expect(
      adapter.requests.single.uri,
      Uri.parse('http://localhost:8000/chat'),
    );
  });
}
