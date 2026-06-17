import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.read(apiClientProvider));
});

class NotificationsRepository {
  final ApiClient _client;

  NotificationsRepository(this._client);

  Future<Map<String, dynamic>> getAll({int page = 1, int limit = 20}) async {
    final response = await _client.dio.get(
      '/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<int> getUnreadCount() async {
    final response = await _client.dio.get('/notifications/unread-count');
    return (response.data as Map<String, dynamic>)['count'] as int;
  }

  Future<void> markAsRead(String id) async {
    await _client.dio.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.dio.patch('/notifications/read-all');
  }
}
