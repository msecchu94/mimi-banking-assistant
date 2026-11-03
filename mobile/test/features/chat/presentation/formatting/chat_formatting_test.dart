import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/money.dart';
import 'package:mimi/features/chat/presentation/formatting/chat_formatting.dart';
import 'package:mimi/features/chat/presentation/formatting/failure_message.dart';

void main() {
  group('formatMoney', () {
    final cases = {
      ('184320.00', Currency.ars): r'$ 184.320,00',
      ('1284650.75', Currency.ars): r'$ 1.284.650,75',
      ('100.00', Currency.ars): r'$ 100,00',
      ('0.50', Currency.ars): r'$ 0,50',
      ('-1000.00', Currency.ars): r'−$ 1.000,00',
      ('25.00', Currency.usd): r'US$ 25,00',
    };
    cases.forEach((input, expected) {
      test('${input.$1} ${input.$2.name} → $expected', () {
        expect(
          formatMoney(Money(amount: input.$1, currency: input.$2)),
          expected,
        );
      });
    });
  });

  group('periodLabel', () {
    ExpensePeriod period(DateTime from, DateTime to) =>
        ExpensePeriod(from: from, to: to);

    test('within one month', () {
      expect(
        periodLabel(period(DateTime.utc(2026, 10), DateTime.utc(2026, 10, 31))),
        '1 – 31 oct 2026',
      );
    });

    test('across months', () {
      expect(
        periodLabel(
          period(DateTime.utc(2026, 9, 15), DateTime.utc(2026, 10, 14)),
        ),
        '15 sep – 14 oct 2026',
      );
    });

    test('across years', () {
      expect(
        periodLabel(period(DateTime.utc(2025, 12, 15), DateTime.utc(2026, 1))),
        '15 dic 2025 – 1 ene 2026',
      );
    });
  });

  test('cardLabel names brand, type and last four digits', () {
    const card = BankCard(
      id: 'c-1',
      brand: CardBrand.visa,
      type: CardType.debit,
      lastFour: '4821',
      status: CardStatus.active,
    );

    expect(cardLabel(card), 'Visa Débito •••• 4821');
  });

  test('card brand, type and status read in Spanish', () {
    expect(cardBrandLabel(CardBrand.visa), 'Visa');
    expect(cardBrandLabel(CardBrand.mastercard), 'Mastercard');
    expect(cardTypeLabel(CardType.credit), 'Crédito');
    expect(cardTypeLabel(CardType.debit), 'Débito');
    expect(cardStatusLabel(CardStatus.active), 'Activa');
    expect(cardStatusLabel(CardStatus.frozen), 'Congelada');
  });

  group('failure messages', () {
    test('only an unavailable conversation ends it', () {
      for (final code in BackendErrorCode.values) {
        final failure = BackendFailure(code: code, requestId: 'r-1');
        expect(
          endsConversation(failure),
          code == BackendErrorCode.conversationNotFound ||
              code == BackendErrorCode.conversationClosed,
          reason: '$code',
        );
        expect(failureMessage(failure), isNotEmpty);
      }
      expect(endsConversation(const ConnectionFailure()), isFalse);
    });

    test('a connection failure asks to check the connection', () {
      expect(failureMessage(const ConnectionFailure()), contains('conexión'));
    });
  });
}
