import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/money.dart';
import 'package:mimi/features/home/domain/models/account.dart';
import 'package:mimi/features/home/domain/models/home_summary.dart';
import 'package:mimi/features/home/presentation/home_view_data.dart';

import '../home_fixtures.dart';

void main() {
  final now = DateTime.now();

  test('shows the backend balance and account, with the static alias', () {
    final data = homeViewDataFrom(
      HomeSummary(account: savings, recentTransactions: const []),
      now: now,
    );

    expect(data.currency, 'ARS');
    expect(data.balance, r'$ 1.284.650,75');
    expect(data.account.title, 'Caja de ahorro · ARS');
    expect(data.account.status, 'Activa · Lucía Fernández');
    expect(data.account.alias, 'lucia.fernandez.ars');
    expect(data.transactions, isEmpty);
  });

  test('labels an inactive account', () {
    final data = homeViewDataFrom(
      HomeSummary(
        account: savings.copyWith(status: AccountStatus.inactive),
        recentTransactions: const [],
      ),
      now: now,
    );

    expect(data.account.status, 'Inactiva · Lucía Fernández');
  });

  test('describes each transaction with its day, time and category', () {
    final older = Transaction(
      id: 't-4',
      description: 'YPF',
      amount: Money(amount: '15000.00', currency: Currency.ars),
      type: TransactionType.debit,
      category: TransactionCategory.fuel,
      occurredAt: DateTime(2025, 10, 26, 9, 10).toUtc(),
    );
    final data = homeViewDataFrom(
      HomeSummary(
        account: savings,
        recentTransactions: [...recentTransactions(), older],
      ),
      now: now,
    );

    expect(
      [
        for (final t in data.transactions)
          (t.title, t.detail, t.amount, t.isCredit, t.category),
      ],
      [
        (
          'Supermercado Día',
          'Hoy, 12:42 · Supermercado',
          r'$ 32.480,50',
          false,
          TransactionCategory.groceries,
        ),
        (
          'Martín López',
          'Hoy, 10:18 · Transferencias',
          r'$ 85.000,00',
          true,
          TransactionCategory.transfer,
        ),
        (
          'Personal',
          'Ayer, 18:05 · Servicios',
          r'$ 18.900,00',
          false,
          TransactionCategory.utilities,
        ),
        (
          'YPF',
          '26 oct, 09:10 · Combustible',
          r'$ 15.000,00',
          false,
          TransactionCategory.fuel,
        ),
      ],
    );
  });
}
