import '../../domain/models/chat_ui.dart';
import '../../domain/models/money.dart';

/// Formats a backend amount for display, e.g. `$ 184.320,00`.
///
/// Works on the backend's decimal string; the amount is never converted to a
/// floating-point number.
String formatMoney(Money money) {
  final amount = money.amount;
  final negative = amount.startsWith('-');
  final [whole, cents] = (negative ? amount.substring(1) : amount).split('.');

  final grouped = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) grouped.write('.');
    grouped.write(whole[i]);
  }

  final symbol = switch (money.currency) {
    Currency.ars => r'$',
    Currency.usd => r'US$',
  };
  return '${negative ? '−' : ''}$symbol $grouped,$cents';
}

String categoryLabel(TransactionCategory category) => switch (category) {
  TransactionCategory.groceries => 'Supermercado',
  TransactionCategory.dining => 'Gastronomía',
  TransactionCategory.transport => 'Transporte',
  TransactionCategory.fuel => 'Combustible',
  TransactionCategory.utilities => 'Servicios',
  TransactionCategory.subscriptions => 'Suscripciones',
  TransactionCategory.entertainment => 'Entretenimiento',
  TransactionCategory.shopping => 'Compras',
  TransactionCategory.transfer => 'Transferencias',
  TransactionCategory.other => 'Otros',
};

const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// A transaction's amount with its direction, e.g. `− $ 17.650,00` or
/// `+ $ 150.000,00`, as on Home.
///
/// The sign comes from [Transaction.type], never from the amount.
String transactionAmountLabel(Transaction transaction) {
  final sign = switch (transaction.type) {
    TransactionType.debit => '−',
    TransactionType.credit => '+',
  };
  return '$sign ${formatMoney(transaction.amount)}';
}

/// A compact day in the device's timezone, e.g. `26 oct`.
String shortDateLabel(DateTime timestamp) {
  final local = timestamp.toLocal();
  return '${local.day} ${_months[local.month - 1]}';
}

/// A period of whole days, e.g. `1 – 31 oct 2026`.
String periodLabel(ExpensePeriod period) {
  final ExpensePeriod(:from, :to) = period;
  String day(DateTime date) => '${date.day}';
  String month(DateTime date) => _months[date.month - 1];

  if (from.year != to.year) {
    return '${day(from)} ${month(from)} ${from.year} – '
        '${day(to)} ${month(to)} ${to.year}';
  }
  if (from.month != to.month) {
    return '${day(from)} ${month(from)} – ${day(to)} ${month(to)} ${to.year}';
  }
  return '${day(from)} – ${day(to)} ${month(to)} ${to.year}';
}

/// E.g. `Visa Débito •••• 4821`.
String cardLabel(BankCard card) =>
    '${cardBrandLabel(card.brand)} ${cardTypeLabel(card.type)} '
    '•••• ${card.lastFour}';

String cardBrandLabel(CardBrand brand) => switch (brand) {
  CardBrand.visa => 'Visa',
  CardBrand.mastercard => 'Mastercard',
};

String cardTypeLabel(CardType type) => switch (type) {
  CardType.debit => 'Débito',
  CardType.credit => 'Crédito',
};

String cardStatusLabel(CardStatus status) => switch (status) {
  CardStatus.active => 'Activa',
  CardStatus.frozen => 'Congelada',
};
