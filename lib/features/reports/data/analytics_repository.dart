import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.read(apiClientProvider));
});

class AnalyticsRepository {
  final ApiClient _client;

  AnalyticsRepository(this._client);

  Future<List<Map<String, dynamic>>> spendingByCategory(
    String startDate,
    String endDate,
  ) async {
    final response = await _client.dio.get(
      '/analytics/spending-by-category',
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> incomeVsExpense({int months = 6}) async {
    final response = await _client.dio.get(
      '/analytics/income-vs-expense',
      queryParameters: {'months': months},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> savingsTrend({int months = 6}) async {
    final response = await _client.dio.get(
      '/analytics/savings-trend',
      queryParameters: {'months': months},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
