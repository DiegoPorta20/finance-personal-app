import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_period.dart';
import '../domain/transaction_model.dart';
import '../data/transactions_repository.dart';

/// Periodo seleccionado en Movimientos (Diario/Semanal/Mensual/Anual).
final transactionsPeriodProvider =
    StateProvider<TimePeriod>((ref) => TimePeriod.monthly);

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final repo = ref.read(transactionsRepositoryProvider);
    final data = await repo.getAll();
    return data.map(Transaction.fromJson).toList();
  }

  Future<void> addTransaction({
    required String type,
    required int amount,
    required String date,
    required String accountId,
    required String categoryId,
    String? note,
  }) async {
    final repo = ref.read(transactionsRepositoryProvider);
    final data = <String, dynamic>{
      'type': type,
      'amount': amount,
      'date': date,
      'accountId': accountId,
      'categoryId': categoryId,
    };
    if (note != null) data['note'] = note;
    await repo.create(data);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
