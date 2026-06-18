import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/env.dart';

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  /// Se invoca cuando una request (no-auth) devuelve 401 (sesión expirada).
  /// Lo conecta FinanceApp para cerrar sesión sin crear dependencia circular.
  void Function()? onUnauthorized;

  ApiClient({
    String? baseUrl,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // 401 en cualquier endpoint que NO sea de auth = sesión expirada.
          // (El 401 de /auth/login es "credenciales inválidas", no logout.)
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/')) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'access_token');
  }
}
