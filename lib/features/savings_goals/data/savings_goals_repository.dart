import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';

final savingsGoalsRepositoryProvider =
    Provider<SavingsGoalsRepository>((ref) {
  return SavingsGoalsRepository(ref.read(apiClientProvider));
});

class SavingsGoalsRepository {
  final ApiClient _client;

  SavingsGoalsRepository(this._client);

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _client.dio.get('/savings-goals');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _client.dio.post('/savings-goals', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _client.dio.patch('/savings-goals/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addFunds(String id, int amount) async {
    final response = await _client.dio.patch(
      '/savings-goals/$id/add-funds',
      data: {'amount': amount},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/savings-goals/$id');
  }
}
