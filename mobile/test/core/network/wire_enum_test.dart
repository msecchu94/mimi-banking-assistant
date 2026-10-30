import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/network/wire_enum.dart';

enum _Sample { ready, waitingConfirmation, ars }

void main() {
  group('decodeWireEnum', () {
    test('decodes SCREAMING_SNAKE_CASE contract values', () {
      expect(decodeWireEnum(_Sample.values, 'READY'), _Sample.ready);
      expect(
        decodeWireEnum(_Sample.values, 'WAITING_CONFIRMATION'),
        _Sample.waitingConfirmation,
      );
      expect(decodeWireEnum(_Sample.values, 'ARS'), _Sample.ars);
    });

    test('returns null for unknown or differently cased values', () {
      expect(decodeWireEnum(_Sample.values, 'CLOSED'), isNull);
      expect(decodeWireEnum(_Sample.values, 'ready'), isNull);
      expect(decodeWireEnum(_Sample.values, 'waitingConfirmation'), isNull);
    });
  });
}
