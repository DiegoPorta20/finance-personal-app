import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Formats an amount in cents to a currency string.
  /// Example: 150000 -> "$1,500.00"
  static String format(int cents, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(cents / 100);
  }

  /// Formats with default symbol.
  static String formatDefault(int cents) {
    return _formatter.format(cents / 100);
  }
}
