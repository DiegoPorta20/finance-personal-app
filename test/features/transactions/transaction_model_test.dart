import 'package:flutter_test/flutter_test.dart';
import 'package:finance_personal_app/features/transactions/domain/transaction_model.dart';

void main() {
  group('Transaction', () {
    test('fromJson parses flat fields', () {
      final tx = Transaction.fromJson({
        'id': 'tx-1',
        'type': 'expense',
        'amount': 5000,
        'date': '2026-06-15T00:00:00.000Z',
        'note': 'Lunch',
        'accountId': 'acc-1',
        'categoryId': 'cat-1',
      });

      expect(tx.id, 'tx-1');
      expect(tx.type, 'expense');
      expect(tx.amount, 5000);
      expect(tx.note, 'Lunch');
      expect(tx.isIncome, false);
    });

    test('fromJson parses nested category and account', () {
      final tx = Transaction.fromJson({
        'id': 'tx-1',
        'type': 'income',
        'amount': 500000,
        'date': '2026-06-01T00:00:00.000Z',
        'accountId': 'acc-1',
        'categoryId': 'cat-salary',
        'category': {'name': 'Sueldo fijo', 'icon': 'payments'},
        'account': {'name': 'Banco Principal'},
      });

      expect(tx.categoryName, 'Sueldo fijo');
      expect(tx.categoryIcon, 'payments');
      expect(tx.accountName, 'Banco Principal');
      expect(tx.isIncome, true);
    });

    test('isIncome returns true for income type', () {
      const tx = Transaction(
        id: '1', type: 'income', amount: 100, date: null,
        accountId: 'a', categoryId: 'c',
      );
      expect(tx.isIncome, true);
    });

    test('isIncome returns false for expense type', () {
      const tx = Transaction(
        id: '1', type: 'expense', amount: 100, date: null,
        accountId: 'a', categoryId: 'c',
      );
      expect(tx.isIncome, false);
    });
  });
}
