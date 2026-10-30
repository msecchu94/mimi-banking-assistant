import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/features/chat/domain/models/money.dart';

void main() {
  test('keeps the backend decimal string unchanged', () {
    final money = Money(amount: '25000.00', currency: Currency.ars);

    expect(money.amount, '25000.00');
    expect(money, Money(amount: '25000.00', currency: Currency.ars));
    expect(money, isNot(Money(amount: '25000.00', currency: Currency.usd)));
  });

  test('rejects amounts without exactly two decimals', () {
    for (final amount in ['25000', '25000.5', '25000.001', '2.5e4', ' 1.00']) {
      expect(
        () => Money(amount: amount, currency: Currency.ars),
        throwsFormatException,
        reason: amount,
      );
    }
  });
}
