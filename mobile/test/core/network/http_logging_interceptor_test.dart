import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/network/http_logging_interceptor.dart';

import '../../helpers/fake_http_client_adapter.dart';

void main() {
  late List<String> logs;

  Dio dioWith(FakeHttpClientAdapter adapter) =>
      Dio(BaseOptions(baseUrl: 'http://localhost:8000'))
        ..httpClientAdapter = adapter
        ..interceptors.add(HttpLoggingInterceptor(logs.add));

  setUp(() => logs = []);

  test('logs method, path and status but never bodies', () async {
    final dio = dioWith(
      FakeHttpClientAdapter.json(200, {'message': 'balance 1236480.75 ARS'}),
    );

    await dio.post<Object?>('/chat', data: {'message': 'secret question'});

    expect(logs, hasLength(1));
    expect(logs.single, startsWith('POST /chat → 200'));
    expect(logs.single, isNot(contains('secret')));
    expect(logs.single, isNot(contains('1236480.75')));
  });

  test('logs failed exchanges and passes the error on unchanged', () async {
    final dio = dioWith(FakeHttpClientAdapter.json(404, {'code': 'X'}));

    await expectLater(
      dio.post<Object?>('/chat'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
    expect(logs.single, startsWith('POST /chat → 404'));
  });
}
