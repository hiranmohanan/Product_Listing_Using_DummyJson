import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthRepository {
  AuthRepository(this.api) {
    api.onUnauthorized = refreshAccessToken;
  }
  final ApiService api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<String?>? _refreshInFlight;
  void Function()? onSessionExpired;

  Future<bool> restore() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;
    api.setAccessToken(await _storage.read(key: 'access_token'));
    await refreshAccessToken();
    return await _storage.read(key: 'refresh_token') != null;
  }

  Future<String?> refreshAccessToken() {
    return _refreshInFlight ??= _refreshOnce().whenComplete(
      () => _refreshInFlight = null,
    );
  }

  Future<String?> _refreshOnce() async {
    final token = await _storage.read(key: 'refresh_token');
    if (token == null) return null;
    try {
      final tokens = await api.refresh(token);
      await _save(tokens);
      return tokens['accessToken'] as String?;
    } on DioException catch (error) {
      if (error.response?.statusCode == 400 ||
          error.response?.statusCode == 401) {
        await logout();
        onSessionExpired?.call();
      }
      return null;
    }
  }

  Future<void> login(String username, String password) async =>
      _save(await api.login(username, password));

  Future<void> _save(Map<String, dynamic> tokens) async {
    final access = tokens['accessToken'] as String?;
    final refresh = tokens['refreshToken'] as String?;
    if (access == null || refresh == null) {
      throw StateError('Login response did not contain tokens');
    }
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    api.setAccessToken(access);
  }

  Future<void> logout() async {
    api.setAccessToken(null);
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}
