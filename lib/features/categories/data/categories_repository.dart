import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.read(apiClientProvider));
});

class CategoriesRepository {
  final ApiClient _client;

  CategoriesRepository(this._client);

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _client.dio.get('/categories');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _client.dio.post('/categories', data: data);
    return response.data as Map<String, dynamic>;
  }
}
