import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.read(apiClientProvider));
});

class BudgetRepository {
  final ApiClient _client;

  BudgetRepository(this._client);

  Future<List<Map<String, dynamic>>> getStatus(int month, int year) async {
    final response = await _client.dio.get(
      '/budgets/status',
      queryParameters: {'month': month, 'year': year},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> autoGenerate() async {
    final response = await _client.dio.get('/budgets/auto-generate');
    return response.data as Map<String, dynamic>;
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _client.dio.post('/budgets', data: data);
  }
}
