import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_model.dart';

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    // TODO: Replace with TransactionsRepository call
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockTransactions();
  }

  Future<void> addTransaction({
    required String type,
    required int amount,
    required String date,
    required String accountId,
    required String categoryId,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      final current = state.valueOrNull ?? [];
      final newTx = Transaction(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        amount: amount,
        date: DateTime.parse(date),
        note: note,
        accountId: accountId,
        categoryId: categoryId,
        categoryName: type == 'income' ? 'Ingreso' : 'Gasto',
        categoryIcon: type == 'income' ? 'payments' : 'more_horiz',
      );
      return [newTx, ...current];
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockTransactions();
    });
  }

  List<Transaction> _mockTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        type: 'expense',
        amount: 8500,
        date: now.subtract(const Duration(hours: 2)),
        note: 'Supermercado',
        accountId: '1',
        categoryId: 'food',
        categoryName: 'Alimentacion',
        categoryIcon: 'restaurant',
        accountName: 'Banco Principal',
      ),
      Transaction(
        id: '2',
        type: 'income',
        amount: 500000,
        date: now.subtract(const Duration(days: 1)),
        note: 'Sueldo mensual',
        accountId: '1',
        categoryId: 'salary',
        categoryName: 'Sueldo fijo',
        categoryIcon: 'payments',
        accountName: 'Banco Principal',
      ),
      Transaction(
        id: '3',
        type: 'expense',
        amount: 1599,
        date: now.subtract(const Duration(days: 2)),
        note: 'Netflix',
        accountId: '3',
        categoryId: 'subscriptions',
        categoryName: 'Suscripciones',
        categoryIcon: 'autorenew',
        accountName: 'Billetera Digital',
      ),
      Transaction(
        id: '4',
        type: 'expense',
        amount: 3200,
        date: now.subtract(const Duration(days: 3)),
        note: 'Uber al trabajo',
        accountId: '2',
        categoryId: 'transport',
        categoryName: 'Transporte',
        categoryIcon: 'directions_car',
        accountName: 'Efectivo',
      ),
      Transaction(
        id: '5',
        type: 'expense',
        amount: 15000,
        date: now.subtract(const Duration(days: 5)),
        note: 'Consulta medica',
        accountId: '1',
        categoryId: 'health',
        categoryName: 'Salud',
        categoryIcon: 'local_hospital',
        accountName: 'Banco Principal',
      ),
      Transaction(
        id: '6',
        type: 'income',
        amount: 75000,
        date: now.subtract(const Duration(days: 7)),
        note: 'Proyecto freelance',
        accountId: '3',
        categoryId: 'freelance',
        categoryName: 'Freelance',
        categoryIcon: 'work',
        accountName: 'Billetera Digital',
      ),
    ];
  }
}
