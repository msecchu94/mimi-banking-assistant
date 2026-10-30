import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/network/dio_error_mapper.dart';
import 'package:mimi/core/network/network_exception.dart';

final _options = RequestOptions(path: '/chat');

DioException _badResponse(int statusCode, Object? body) =>
    DioException.badResponse(
      statusCode: statusCode,
      requestOptions: _options,
      response: Response<Object?>(
        requestOptions: _options,
        statusCode: statusCode,
        data: body,
      ),
    );

void main() {
  group('mapDioException', () {
    test('classifies unreachable or slow backends as connection errors', () {
      final errors = [
        DioException.connectionError(requestOptions: _options, reason: 'x'),
        DioException.connectionTimeout(
          timeout: Duration.zero,
          requestOptions: _options,
        ),
        DioException.sendTimeout(
          timeout: Duration.zero,
          requestOptions: _options,
        ),
        DioException.receiveTimeout(
          timeout: Duration.zero,
          requestOptions: _options,
        ),
      ];

      for (final error in errors) {
        expect(
          mapDioException(error),
          isA<ConnectionException>(),
          reason: '${error.type}',
        );
      }
    });

    test('reads a contract error body as an API error', () {
      final result = mapDioException(
        _badResponse(422, {
          'code': 'INSUFFICIENT_FUNDS',
          'message': 'The account does not have sufficient funds.',
          'request_id': 'req-1',
          'timestamp': '2026-10-09T16:31:04Z',
        }),
      );

      expect(
        result,
        isA<ApiErrorException>()
            .having((e) => e.statusCode, 'statusCode', 422)
            .having((e) => e.code, 'code', 'INSUFFICIENT_FUNDS')
            .having((e) => e.requestId, 'requestId', 'req-1'),
      );
    });

    test('treats a non-contract error body as an invalid response', () {
      final bodies = <Object?>[
        // FastAPI's default body for unknown routes and methods.
        {'detail': 'Not Found'},
        '<html>Bad Gateway</html>',
        null,
      ];

      for (final body in bodies) {
        expect(
          mapDioException(_badResponse(404, body)),
          isA<InvalidResponseException>().having(
            (e) => e.statusCode,
            'statusCode',
            404,
          ),
          reason: '$body',
        );
      }
    });

    test('classifies other Dio failures as unknown', () {
      final errors = [
        DioException.badCertificate(requestOptions: _options),
        DioException.requestCancelled(requestOptions: _options, reason: null),
        DioException(requestOptions: _options, error: StateError('x')),
      ];

      for (final error in errors) {
        expect(
          mapDioException(error),
          isA<UnknownNetworkException>(),
          reason: '${error.type}',
        );
      }
    });
  });
}
