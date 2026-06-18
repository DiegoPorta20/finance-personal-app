import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';
import '../domain/dashboard_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

class DashboardRepository {
  final ApiClient _client;

  DashboardRepository(this._client);

  Future<List<AccountSummary>> getAccounts() async {
    final response = await _client.dio.get('/accounts');
    final list = response.data as List;
    return list.map((json) {
      final j = json as Map<String, dynamic>;
      return AccountSummary(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        balance: j['balance'] as int? ?? 0,
        icon: _mapIconType(j['type'] as String),
      );
    }).toList();
  }

  Future<List<RecentTransaction>> getRecentTransactions() async {
    final response = await _client.dio.get('/transactions');
    // El endpoint devuelve { data: [...], meta: {...} } (paginado).
    final raw = response.data;
    final list = (raw is Map ? raw['data'] as List : raw as List);
    return list.take(5).map((json) {
      final j = json as Map<String, dynamic>;
      final category = j['category'] as Map<String, dynamic>?;
      return RecentTransaction(
        id: j['id'] as String,
        description: (j['note'] as String?) ?? category?['name'] as String? ?? '',
        categoryName: category?['name'] as String? ?? '',
        categoryIcon: category?['icon'] as String? ?? 'more_horiz',
        amount: j['amount'] as int,
        type: j['type'] as String,
        date: DateTime.parse(j['date'] as String),
      );
    }).toList();
  }

  IconType _mapIconType(String type) {
    return switch (type) {
      'bank' => IconType.bank,
      'cash' => IconType.cash,
      'digital_wallet' => IconType.wallet,
      _ => IconType.bank,
    };
  }
}
