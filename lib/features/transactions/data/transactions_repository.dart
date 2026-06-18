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

  Future<({List<Map<String, dynamic>> items, bool hasMore})> getPage({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/transactions',
      queryParameters: {'page': page, 'limit': limit},
    );
    // El endpoint devuelve { data: [...], meta: {page, totalPages, ...} }.
    final raw = response.data;
    final list = (raw is Map ? raw['data'] as List : raw as List)
        .cast<Map<String, dynamic>>();
    final meta = raw is Map ? raw['meta'] as Map<String, dynamic>? : null;
    final totalPages = (meta?['totalPages'] as int?) ?? 1;
    return (items: list, hasMore: page < totalPages);
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
