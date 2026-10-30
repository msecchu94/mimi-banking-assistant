import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A Dio adapter that answers every request with a programmed result and
/// records what was sent.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this._respond);

  /// Responds with [body] encoded as JSON.
  factory FakeHttpClientAdapter.json(int statusCode, Object? body) =>
      FakeHttpClientAdapter(
        (_) => ResponseBody.fromString(
          jsonEncode(body),
          statusCode,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );

  /// Responds with a non-JSON body.
  factory FakeHttpClientAdapter.text(int statusCode, String body) =>
      FakeHttpClientAdapter(
        (_) => ResponseBody.fromString(
          body,
          statusCode,
          headers: {
            Headers.contentTypeHeader: ['text/html'],
          },
        ),
      );

  /// Fails every request with the [DioException] built by [error].
  factory FakeHttpClientAdapter.failing(
    DioException Function(RequestOptions options) error,
  ) => FakeHttpClientAdapter((options) => throw error(options));

  final ResponseBody Function(RequestOptions options) _respond;

  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}
