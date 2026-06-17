import 'package:flutter_test/flutter_test.dart';
import 'package:finance_personal_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats zero cents correctly', () {
      expect(CurrencyFormatter.format(0), '\$0.00');
    });

    test('formats positive amount in cents', () {
      expect(CurrencyFormatter.format(150000), '\$1,500.00');
    });

    test('formats small amount', () {
      expect(CurrencyFormatter.format(99), '\$0.99');
    });

    test('formats single cent', () {
      expect(CurrencyFormatter.format(1), '\$0.01');
    });

    test('formats large amount', () {
      expect(CurrencyFormatter.format(10000000), '\$100,000.00');
    });

    test('formats with custom symbol', () {
      expect(CurrencyFormatter.format(5000, symbol: 'MX\$'), 'MX\$50.00');
    });

    test('formats with euro symbol', () {
      expect(CurrencyFormatter.format(25050, symbol: '\u20AC'), '\u20AC250.50');
    });

    test('formatDefault uses dollar sign', () {
      expect(CurrencyFormatter.formatDefault(10000), '\$100.00');
    });
  });
}
