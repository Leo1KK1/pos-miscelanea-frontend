import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_config.dart';

class AuthService {
  AuthService({Dio? dio, FlutterSecureStorage? storage, this.baseUrl})
    : _dio = dio ?? Dio(),
      _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  final String? baseUrl;

  Future<String> iniciarSesion({required String email, required String password}) async {
    String apiBaseUrl;
    try {
      apiBaseUrl = baseUrl ?? ApiConfig.baseUrl;
    } on ApiConfigurationException {
      throw const AuthException('Falta configurar la dirección del servidor.');
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$apiBaseUrl/api/auth/login',
        data: {'email': email.trim(), 'password': password},
        options: Options(
          contentType: Headers.jsonContentType,
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      final body = response.data;
      final accessToken = body?['access_token'];
      final refreshToken = body?['refresh_token'];
      final usuario = body?['usuario'];
      final correoUsuario = usuario is Map ? usuario['email'] : null;
      if (accessToken is! String || refreshToken is! String || correoUsuario is! String) {
        throw const AuthException('El servidor devolvió una respuesta incompleta.');
      }
      await _storage.delete(key: 'selected_store_id');
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      return correoUsuario;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw const AuthException('Revisa tu correo o contraseña.');
      }
      if (error.response?.statusCode == 400) {
        throw const AuthException('Revisa los datos e inténtalo de nuevo.');
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const AuthException('No hay conexión. Conéctate a internet para iniciar sesión.');
      }
      throw const AuthException('No fue posible iniciar sesión. Inténtalo de nuevo.');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}
