import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    await _client.saveToken(data['accessToken'] as String);
    return data;
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await _client.dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
    });
    final data = response.data as Map<String, dynamic>;
    await _client.saveToken(data['accessToken'] as String);
    return data;
  }

  Future<void> logout() async {
    await _client.deleteToken();
  }

  /// Token guardado (si existe) para restaurar la sesión al abrir la app.
  Future<String?> currentToken() => _client.getToken();
}
