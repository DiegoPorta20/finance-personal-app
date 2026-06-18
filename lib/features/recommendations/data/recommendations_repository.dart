import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';
import '../domain/recommendation_model.dart';

final recommendationsRepositoryProvider =
    Provider<RecommendationsRepository>((ref) {
  return RecommendationsRepository(ref.read(apiClientProvider));
});

class RecommendationsRepository {
  final ApiClient _client;

  RecommendationsRepository(this._client);

  Future<List<Recommendation>> getAll() async {
    final response = await _client.dio.get('/recommendations');
    final list = (response.data as List).cast<Map<String, dynamic>>();
    return list.map(Recommendation.fromJson).toList();
  }
}
