import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_period.dart';
import '../domain/transaction_model.dart';
import '../data/transactions_repository.dart';

/// Periodo seleccionado en Movimientos (Diario/Semanal/Mensual/Anual).
final transactionsPeriodProvider =
    StateProvider<TimePeriod>((ref) => TimePeriod.monthly);

/// Texto de búsqueda para filtrar movimientos (nota o categoría).
final transactionsSearchProvider = StateProvider<String>((ref) => '');

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  bool get hasMore => _hasMore;

  @override
  Future<List<Transaction>> build() async {
    _page = 1;
    final repo = ref.read(transactionsRepositoryProvider);
    final result = await repo.getPage(page: 1);
    _hasMore = result.hasMore;
    return result.items.map(Transaction.fromJson).toList();
  }

  /// Carga la siguiente página y la agrega a la lista (scroll infinito).
  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    final repo = ref.read(transactionsRepositoryProvider);
    try {
      final result = await repo.getPage(page: _page + 1);
      _page += 1;
      _hasMore = result.hasMore;
      final current = state.valueOrNull ?? [];
      state = AsyncData([
        ...current,
        ...result.items.map(Transaction.fromJson),
      ]);
    } finally {
      _loadingMore = false;
    }
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

  Future<void> updateTransaction({
    required String id,
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
    await repo.update(id, data);
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(String id) async {
    final repo = ref.read(transactionsRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
