import 'package:flutter_test/flutter_test.dart';
import 'package:finance_personal_app/features/accounts/domain/account_model.dart';

void main() {
  group('Account', () {
    test('fromJson parses all fields', () {
      final account = Account.fromJson({
        'id': 'acc-1',
        'name': 'Banco Principal',
        'type': 'bank',
        'currency': 'USD',
        'balance': 850000,
      });

      expect(account.id, 'acc-1');
      expect(account.name, 'Banco Principal');
      expect(account.type, 'bank');
      expect(account.currency, 'USD');
      expect(account.balance, 850000);
    });

    test('fromJson defaults currency to USD', () {
      final account = Account.fromJson({
        'id': 'acc-1',
        'name': 'Test',
        'type': 'cash',
      });

      expect(account.currency, 'USD');
    });

    test('fromJson defaults balance to 0', () {
      final account = Account.fromJson({
        'id': 'acc-1',
        'name': 'Test',
        'type': 'cash',
      });

      expect(account.balance, 0);
    });

    test('typeLabel returns Spanish labels', () {
      expect(
        Account.fromJson({'id': '1', 'name': 'T', 'type': 'bank'}).typeLabel,
        'Banco',
      );
      expect(
        Account.fromJson({'id': '1', 'name': 'T', 'type': 'cash'}).typeLabel,
        'Efectivo',
      );
      expect(
        Account.fromJson({'id': '1', 'name': 'T', 'type': 'digital_wallet'}).typeLabel,
        'Billetera Digital',
      );
    });

    test('toCreateJson excludes id and balance', () {
      const account = Account(
        id: 'acc-1',
        name: 'Test',
        type: 'bank',
        currency: 'USD',
        balance: 50000,
      );

      final json = account.toCreateJson();
      expect(json, {'name': 'Test', 'type': 'bank', 'currency': 'USD'});
      expect(json.containsKey('id'), false);
      expect(json.containsKey('balance'), false);
    });
  });
}
