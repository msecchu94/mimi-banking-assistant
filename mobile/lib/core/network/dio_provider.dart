import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/api_base_url_provider.dart';
import 'http_logging_interceptor.dart';

part 'dio_provider.g.dart';

/// The HTTP client for the Mimi backend.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(apiBaseUrlProvider).toString(),
      connectTimeout: const Duration(seconds: 10),
      // Free-text messages are interpreted by an LLM before the backend
      // answers.
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: {Headers.acceptHeader: Headers.jsonContentType},
    ),
  );
  if (kDebugMode) dio.interceptors.add(HttpLoggingInterceptor(debugPrint));
  ref.onDispose(dio.close);
  return dio;
}
