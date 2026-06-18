import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';

final transactionsRepositoryProvider =
    Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.read(apiClientProvider));
});

class TransactionsRepository {
  final ApiClient _client;

  TransactionsRepository(this._client);

  Future<List<Map<String, dynamic>>> getAll({
    String? type,
    String? accountId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;
    if (accountId != null) queryParams['accountId'] = accountId;

    final response =
        await _client.dio.get('/transactions', queryParameters: queryParams);
    // El endpoint devuelve { data: [...], meta: {...} } (paginado).
    final raw = response.data;
    final list = (raw is Map ? raw['data'] as List : raw as List);
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _client.dio.post('/transactions', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _client.dio.patch('/transactions/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/transactions/$id');
  }
}
