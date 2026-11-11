import '../../chat/domain/models/chat_ui.dart';
import '../../chat/presentation/formatting/chat_formatting.dart';
import '../domain/models/account.dart';
import '../domain/models/home_summary.dart';

/// Presentation-only identity copy. The backend exposes neither the
/// customer's profile nor an account alias, so these stay static.
const homeFirstName = 'Lucía';
const homeAccountDescription = 'Tu caja de ahorro en pesos';
const homeAccountHolder = 'Lucía Fernández';
const homeAccountAlias = 'lucia.fernandez.ars';

/// Home content, ready to display.
///
/// Amounts are formatted from backend values, never calculated here.
class HomeViewData {
  const HomeViewData({
    required this.currency,
    required this.balance,
    required this.account,
    required this.transactions,
  });

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
    required this.id,
    required this.title,
    required this.detail,
    required this.amount,
    required this.isCredit,
    required this.category,
  });

  /// The backend transaction id; keeps a row's identity across refreshes.
  final String id;
  final String title;
  final String detail;

  /// What the transaction was for; Home only uses it to pick the row's icon.
  final TransactionCategory category;

  /// Unsigned display amount; the sign is derived from [isCredit].
  final String amount;
  final bool isCredit;
}

/// Maps the backend [summary] to Home content; [now] decides the
/// "Hoy"/"Ayer" day labels.
HomeViewData homeViewDataFrom(HomeSummary summary, {required DateTime now}) {
  final account = summary.account;
  final currency = account.balance.currency.name.toUpperCase();
  return HomeViewData(
    currency: currency,
    balance: formatMoney(account.balance),
    account: HomeAccountSummary(
      title: '${account.name} · $currency',
      status: '${_statusLabel(account.status)} · $homeAccountHolder',
      alias: homeAccountAlias,
    ),
    transactions: [
      for (final transaction in summary.recentTransactions)
        HomeTransaction(
          id: transaction.id,
          title: transaction.description,
          detail:
              '${_dayTimeLabel(transaction.occurredAt, now)} · '
              '${categoryLabel(transaction.category)}',
          amount: formatMoney(transaction.amount),
          isCredit: transaction.type == TransactionType.credit,
          category: transaction.category,
        ),
    ],
  );
}

String _statusLabel(AccountStatus status) => switch (status) {
  AccountStatus.active => 'Activa',
  AccountStatus.inactive => 'Inactiva',
};

/// A day and time in the device's timezone, e.g. `Hoy, 12:42`,
/// `Ayer, 18:05` or `26 oct, 09:10`.
String _dayTimeLabel(DateTime timestamp, DateTime now) {
  final local = timestamp.toLocal();
  final today = now.toLocal();
  bool isDay(DateTime day) =>
      local.year == day.year &&
      local.month == day.month &&
      local.day == day.day;

  final day = isDay(today)
      ? 'Hoy'
      : isDay(DateTime(today.year, today.month, today.day - 1))
      ? 'Ayer'
      : shortDateLabel(timestamp);
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '$day, ${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}
