import 'package:dio/dio.dart';

/// Logs each HTTP exchange as method, path, status and duration.
///
/// Bodies and headers are never logged: they carry financial data. It only
/// observes; errors are classified by `mapDioException`.
class HttpLoggingInterceptor extends Interceptor {
  HttpLoggingInterceptor(this._log);

  static const _startedAtKey = 'http_logging_started_at';

  final void Function(String message) _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logExchange(response.requestOptions, '${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logExchange(
      err.requestOptions,
      '${err.response?.statusCode ?? err.type.name}',
    );
    handler.next(err);
  }

  void _logExchange(RequestOptions options, String outcome) {
    final startedAt = options.extra[_startedAtKey];
    final duration = startedAt is DateTime
        ? ' (${DateTime.now().difference(startedAt).inMilliseconds} ms)'
        : '';
    _log('${options.method} ${options.uri.path} → $outcome$duration');
  }
}
