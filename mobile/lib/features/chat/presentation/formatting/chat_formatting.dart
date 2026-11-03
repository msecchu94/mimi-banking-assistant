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

/// A day and time in the device's timezone, e.g. `3 nov 2026, 19:58`.
String dateTimeLabel(DateTime timestamp) {
  final local = timestamp.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${local.day} ${_months[local.month - 1]} ${local.year}, '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}

/// A long reference shortened for display, e.g. `bbb202a2…ba39`. The full
/// reference is kept wherever it is used, e.g. when sharing.
String shortReferenceLabel(String reference) {
  const head = 8;
  const tail = 4;
  if (reference.length <= head + tail + 1) return reference;
  return '${reference.substring(0, head)}…'
      '${reference.substring(reference.length - tail)}';
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

const _monthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

/// Labels for two compared periods, in the order given.
///
/// A whole calendar month reads as its name, e.g. `Octubre`, with its year
/// when the two periods fall in different years; any other period uses
/// [periodLabel].
(String, String) comparisonPeriodLabels(
  ExpensePeriod current,
  ExpensePeriod previous,
) {
  final withYear = current.from.year != previous.from.year;
  String label(ExpensePeriod period) {
    final ExpensePeriod(:from, :to) = period;
    final isWholeMonth =
        from.day == 1 &&
        to.year == from.year &&
        to.month == from.month &&
        to.add(const Duration(days: 1)).month != to.month;
    if (!isWholeMonth) return periodLabel(period);
    final name = _monthNames[from.month - 1];
    return withYear ? '$name ${from.year}' : name;
  }

  return (label(current), label(previous));
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

/// A beneficiary's initials, e.g. `DR` for `Diego Romero`: the first letter
/// of the first and last words, or of the only one. Presentation only.
String beneficiaryInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  String first(String word) => String.fromCharCode(word.runes.first);
  final initials = words.length == 1
      ? first(words.first)
      : first(words.first) + first(words.last);
  return initials.toUpperCase();
}

/// The backend's masked reference made easier to read, e.g. `****0044` →
/// `•••• 0044`. Only the mask characters change; anything else is shown as
/// sent.
String accountReferenceLabel(String reference) {
  final mask = RegExp(r'^\*+').firstMatch(reference)?.group(0);
  if (mask == null) return reference;
  final visible = reference.substring(mask.length);
  final dots = '•' * mask.length;
  return visible.isEmpty ? dots : '$dots $visible';
}

/// The text a completed transfer is shared as: its structured data only,
/// with the full operation reference.
String transferShareText(TransferSummaryUi transfer) {
  final amount = transfer.amount;
  return [
    'Transferencia realizada',
    'Monto: ${formatMoney(amount)} ${amount.currency.name.toUpperCase()}',
    'Destinatario: ${transfer.beneficiary}',
    'Fecha: ${dateTimeLabel(transfer.executedAt)}',
    'Operación: ${transfer.transferId}',
  ].join('\n');
}
