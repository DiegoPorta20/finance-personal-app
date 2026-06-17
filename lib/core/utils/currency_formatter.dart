import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/application/user_provider.dart';

final currencySymbolProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final currency = profile?['currency'] as String? ?? 'USD';
  return _symbolFor(currency);
});

String _symbolFor(String code) {
  return switch (code) {
    'USD' => '\$',
    'EUR' => '\u20AC',
    'GBP' => '\u00A3',
    'MXN' => 'MX\$',
    'COP' => 'COL\$',
    'ARS' => 'AR\$',
    'BRL' => 'R\$',
    'PEN' => 'S/',
    'CLP' => 'CLP\$',
    _ => '$code ',
  };
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(int cents, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(cents / 100);
  }

  static String formatDefault(int cents) {
    return format(cents);
  }
}
