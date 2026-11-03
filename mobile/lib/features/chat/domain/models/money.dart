/// A monetary value supplied by the backend.
///
/// [amount] is the backend's decimal string with exactly two decimal places
/// (e.g. `"25000.00"`). It is never converted to a floating-point number: the
/// client displays amounts, the backend calculates them.
final class Money {
  /// Throws a [FormatException] when [amount] is not a two-decimal string.
  Money({required this.amount, required this.currency}) {
    if (!_amountPattern.hasMatch(amount)) {
      throw FormatException('Expected a decimal with two places', amount);
    }
  }

  static final _amountPattern = RegExp(r'^-?\d+\.\d{2}$');

  final String amount;
  final Currency currency;

  @override
  bool operator ==(Object other) =>
      other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => 'Money($amount ${currency.name})';
}

enum Currency { ars, usd }
