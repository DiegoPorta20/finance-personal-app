import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';

final incomeSourcesRepositoryProvider =
    Provider<IncomeSourcesRepository>((ref) {
  return IncomeSourcesRepository(ref.read(apiClientProvider));
});

class IncomeSourcesRepository {
  final ApiClient _client;

  IncomeSourcesRepository(this._client);

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _client.dio.get('/income-sources');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _client.dio.post('/income-sources', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _client.dio.patch('/income-sources/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/income-sources/$id');
  }
}
