/// Fictional DS-04 Home content, displayed until Home is backed by the API.
///
/// Presentation-only: amounts are display strings, never calculated here.
class HomeViewData {
  const HomeViewData({
    required this.firstName,
    required this.accountDescription,
    required this.currency,
    required this.balance,
    required this.account,
    required this.transactions,
  });

  final String firstName;
  final String accountDescription;
  final String currency;
  final String balance;
  final HomeAccountSummary account;
  final List<HomeTransaction> transactions;
}

class HomeAccountSummary {
  const HomeAccountSummary({
    required this.title,
    required this.status,
    required this.alias,
  });

  final String title;
  final String status;
  final String alias;
}

class HomeTransaction {
  const HomeTransaction({
    required this.title,
    required this.detail,
    required this.amount,
    required this.isCredit,
  });

  final String title;
  final String detail;

  /// Unsigned display amount; the sign is derived from [isCredit].
  final String amount;
  final bool isCredit;
}

const homeMockData = HomeViewData(
  firstName: 'Lucía',
  accountDescription: 'Tu caja de ahorro en pesos',
  currency: 'ARS',
  balance: r'$ 1.284.650,75',
  account: HomeAccountSummary(
    title: 'Caja de ahorro · ARS',
    status: 'Activa · Lucía Fernández',
    alias: 'lucia.fernandez.ars',
  ),
  transactions: [
    HomeTransaction(
      title: 'Supermercado Día',
      detail: 'Hoy, 12:42 · Débito',
      amount: r'$ 32.480,50',
      isCredit: false,
    ),
    HomeTransaction(
      title: 'Martín López',
      detail: 'Hoy, 10:18 · Recibida',
      amount: r'$ 85.000,00',
      isCredit: true,
    ),
    HomeTransaction(
      title: 'Personal',
      detail: 'Ayer, 18:05 · Servicio',
      amount: r'$ 18.900,00',
      isCredit: false,
    ),
  ],
);
