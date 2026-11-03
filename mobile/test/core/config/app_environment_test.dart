import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/config/app_environment.dart';

void main() {
  group('AppEnvironment.fromName', () {
    test('resolves every supported environment by name', () {
      for (final environment in AppEnvironment.values) {
        expect(AppEnvironment.fromName(environment.name), environment);
      }
    });

    test('rejects a missing environment instead of defaulting', () {
      expect(() => AppEnvironment.fromName(''), throwsArgumentError);
    });

    test('rejects an unknown environment', () {
      expect(() => AppEnvironment.fromName('staging'), throwsArgumentError);
    });
  });
}
