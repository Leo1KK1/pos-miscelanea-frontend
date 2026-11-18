import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_config.dart';

class StoreService {
  StoreService({Dio? dio, FlutterSecureStorage? storage, this.baseUrl})
    : _dio = dio ?? Dio(),
      _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final String? baseUrl;

  String get _apiBaseUrl {
    try {
      return baseUrl ?? ApiConfig.baseUrl;
    } on ApiConfigurationException {
      throw const StoreException('Falta configurar la dirección del servidor.');
    }
  }

  Future<List<StoreMembership>> listarTiendas() async {
    final response = await _authenticatedGet('$_apiBaseUrl/api/tiendas');
    final raw = response.data?['tiendas'];
    if (raw is! List) throw const StoreException('Respuesta inválida al consultar tiendas.');
    return raw.whereType<Map>().map((item) => StoreMembership.fromJson(
      Map<String, dynamic>.from(item),
    )).toList(growable: false);
  }

  Future<Map<String, dynamic>> seleccionarTienda(String id) async {
    final response = await _authenticatedGet('$_apiBaseUrl/api/tiendas/${Uri.encodeComponent(id)}/contexto');
    final data = response.data;
    final tienda = data?['tienda_activa'];
    if (tienda is! Map || tienda['id'] != id || tienda['nombre'] is! String) {
      throw const StoreException('El servidor no confirmó la tienda seleccionada.');
    }
    await _storage.write(key: 'selected_store_id', value: tienda['id'] as String);
    return Map<String, dynamic>.from(tienda);
  }

  Future<Response<Map<String, dynamic>>> _authenticatedGet(String path) async {
    final accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null || accessToken.isEmpty) {
      throw const StoreException('Tu sesión no está disponible. Inicia sesión nuevamente.', sessionExpired: true);
    }
    try {
      final response = await _getWithToken(path, accessToken);
      return response;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401) {
        final nuevoToken = await _renovarSesion();
        if (nuevoToken == null) {
          throw const StoreException('Tu sesión expiró. Inicia sesión nuevamente.', sessionExpired: true);
        }
        try {
          return await _getWithToken(path, nuevoToken);
        } on DioException catch (retryError) {
          if (retryError.response?.statusCode == 401) {
            throw const StoreException('Tu sesión expiró. Inicia sesión nuevamente.', sessionExpired: true);
          }
          throw _traducirError(retryError);
        }
      }
      throw _traducirError(error);
    }
  }

  StoreException _traducirError(DioException error) {
    if (error.response?.statusCode == 403) {
      return const StoreException('No tienes acceso a esta tienda. Puede que tu membresía esté inactiva.');
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const StoreException('No hay conexión. Conéctate a internet para consultar y validar tus tiendas.');
    }
    return const StoreException('No fue posible consultar las tiendas. Inténtalo de nuevo.');
  }

  Future<Response<Map<String, dynamic>>> _getWithToken(String path, String token) =>
      _dio.get<Map<String, dynamic>>(
        path,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

  Future<String?> _renovarSesion() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_apiBaseUrl/api/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(contentType: Headers.jsonContentType,
          receiveTimeout: const Duration(seconds: 15)),
      );
      final access = response.data?['access_token'];
      final refresh = response.data?['refresh_token'];
      if (access is! String || refresh is! String) return null;
      await _storage.write(key: 'access_token', value: access);
      await _storage.write(key: 'refresh_token', value: refresh);
      return access;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) return null;
      throw _traducirError(error);
    }
  }
}

class StoreMembership {
  const StoreMembership({required this.id, required this.nombre, required this.rol});

  final String id;
  final String nombre;
  final String rol;

  factory StoreMembership.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nombre = json['nombre'];
    final rol = json['rol'];
    if (id is! String || nombre is! String || rol is! String) {
      throw const StoreException('La respuesta contiene una tienda incompleta.');
    }
    return StoreMembership(id: id, nombre: nombre, rol: rol);
  }
}

class StoreException implements Exception {
  const StoreException(this.message, {this.sessionExpired = false});
  final String message;
  final bool sessionExpired;
}
