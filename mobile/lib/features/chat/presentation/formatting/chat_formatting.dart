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
  TransactionCategory.dining => 'Restaurantes',
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
String cardLabel(BankCard card) {
  final brand = switch (card.brand) {
    CardBrand.visa => 'Visa',
    CardBrand.mastercard => 'Mastercard',
  };
  final type = switch (card.type) {
    CardType.debit => 'Débito',
    CardType.credit => 'Crédito',
  };
  return '$brand $type •••• ${card.lastFour}';
}

String cardStatusLabel(CardStatus status) => switch (status) {
  CardStatus.active => 'Activa',
  CardStatus.frozen => 'Congelada',
};
