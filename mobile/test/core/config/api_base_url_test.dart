import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/config/api_base_url.dart';

void main() {
  group('ApiBaseUrl.parse', () {
    test('accepts an absolute http or https URL', () {
      expect(
        ApiBaseUrl.parse('http://localhost:8000'),
        Uri.parse('http://localhost:8000'),
      );
      expect(
        ApiBaseUrl.parse('https://api.example.test/mimi'),
        Uri.parse('https://api.example.test/mimi'),
      );
    });

    test('rejects a missing or unresolved URL instead of defaulting', () {
      expect(() => ApiBaseUrl.parse(''), throwsArgumentError);
    });

    test('rejects URLs the API client cannot use as a base', () {
      for (final value in [
        'localhost:8000',
        '/chat',
        'ftp://localhost',
        'http://',
        'http://localhost:8000?env=dev',
        'http://localhost:8000#chat',
      ]) {
        expect(
          () => ApiBaseUrl.parse(value),
          throwsArgumentError,
          reason: value,
        );
      }
    });
  });
}
