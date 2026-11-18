import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_miscelanea_frontend/auth/auth_service.dart';
import 'package:pos_miscelanea_frontend/stores/store_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  const baseUrl = 'https://api.example.test';

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Dio mockDio(Map<String, dynamic> Function(RequestOptions) handle) {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      try {
        handler.resolve(Response<Map<String, dynamic>>(
          requestOptions: request,
          statusCode: 200,
          data: handle(request),
        ));
      } on DioException catch (error) {
        handler.reject(error);
      }
    }));
    return dio;
  }

  DioException httpError(RequestOptions request, int status) => DioException(
    requestOptions: request,
    response: Response(requestOptions: request, statusCode: status),
    type: DioExceptionType.badResponse,
  );

  test('login, listado y selección usan el contrato del backend', () async {
    FlutterSecureStorage.setMockInitialValues({'selected_store_id': 'anterior'});
    final paths = <String>[];
    final dio = mockDio((request) {
      paths.add(request.path);
      switch (request.path) {
        case '$baseUrl/api/auth/login':
          expect(request.data, {'email': 'user@example.com', 'password': 'secret'});
          return {'access_token': 'access', 'refresh_token': 'refresh', 'usuario': {'email': 'user@example.com'}};
        case '$baseUrl/api/tiendas':
          expect(request.headers['Authorization'], 'Bearer access');
          return {'tiendas': [{'id': 'store-1', 'nombre': 'Tienda', 'rol': 'cajero'}]};
        case '$baseUrl/api/tiendas/store-1/contexto':
          return {'tienda_activa': {'id': 'store-1', 'nombre': 'Tienda'}};
        default:
          fail('Ruta inesperada: ${request.path}');
      }
    });
    final auth = AuthService(dio: dio, storage: storage, baseUrl: baseUrl);
    final stores = StoreService(dio: dio, storage: storage, baseUrl: baseUrl);
    expect(await auth.iniciarSesion(email: ' user@example.com ', password: 'secret'), 'user@example.com');
    expect(await storage.read(key: 'selected_store_id'), isNull);
    expect((await stores.listarTiendas()).single.rol, 'cajero');
    await stores.seleccionarTienda('store-1');
    expect(await storage.read(key: 'selected_store_id'), 'store-1');
    expect(paths.length, 3);
  });

  test('401 renueva tokens una vez y reintenta', () async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'old', 'refresh_token': 'refresh'});
    var requests = 0;
    final dio = mockDio((request) {
      if (request.path.endsWith('/refresh')) {
        expect(request.data, {'refresh_token': 'refresh'});
        return {'access_token': 'new', 'refresh_token': 'new-refresh'};
      }
      requests++;
      if (requests == 1) throw httpError(request, 401);
      expect(request.headers['Authorization'], 'Bearer new');
      return {'tiendas': []};
    });
    expect(await StoreService(dio: dio, storage: storage, baseUrl: baseUrl).listarTiendas(), isEmpty);
    expect(requests, 2);
    expect(await storage.read(key: 'refresh_token'), 'new-refresh');
  });

  test('error de conexión al renovar no se presenta como sesión expirada', () async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'old', 'refresh_token': 'refresh'});
    final dio = mockDio((request) {
      if (request.path.endsWith('/refresh')) {
        throw DioException(requestOptions: request, type: DioExceptionType.connectionError);
      }
      throw httpError(request, 401);
    });
    await expectLater(
      () => StoreService(dio: dio, storage: storage, baseUrl: baseUrl).listarTiendas(),
      throwsA(isA<StoreException>().having((e) => e.sessionExpired, 'sessionExpired', false)
        .having((e) => e.message, 'message', contains('No hay conexión'))),
    );
  });

  test('403 tras renovación conserva la sesión', () async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'old', 'refresh_token': 'refresh'});
    var requests = 0;
    final dio = mockDio((request) {
      if (request.path.endsWith('/refresh')) {
        return {'access_token': 'new', 'refresh_token': 'new-refresh'};
      }
      throw httpError(request, ++requests == 1 ? 401 : 403);
    });
    await expectLater(
      () => StoreService(dio: dio, storage: storage, baseUrl: baseUrl).listarTiendas(),
      throwsA(isA<StoreException>().having((e) => e.message, 'message', contains('No tienes acceso'))),
    );
    expect(await storage.read(key: 'access_token'), 'new');
  });
}
