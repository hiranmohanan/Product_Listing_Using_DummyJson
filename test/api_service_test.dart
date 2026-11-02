import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_auth_app/core/api_service.dart';

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ApiEndpointRegistry', () {
    test('defines all static API endpoints and helpers', () {
      expect(ApiEndpointRegistry.baseUrl, 'https://dummyjson.com');
      expect(ApiEndpointRegistry.authPrefix, '/auth/');
      expect(ApiEndpointRegistry.login, '/auth/login');
      expect(ApiEndpointRegistry.refresh, '/auth/refresh');
      expect(ApiEndpointRegistry.products, '/products');
      expect(ApiEndpointRegistry.productSearch, '/products/search');
      expect(ApiEndpointRegistry.productDetail(7), '/products/7');
      expect(ApiEndpointRegistry.product(7), '/products/7');

      expect(ApiEndpointRegistry.isAuthPath('/auth/login'), isTrue);
      expect(ApiEndpointRegistry.isAuthPath('/auth/refresh'), isTrue);
      expect(ApiEndpointRegistry.isAuthPath('/products'), isFalse);
    });

    test('ApiEndpoints alias points to ApiEndpointRegistry', () {
      expect(ApiEndpoints.baseUrl, ApiEndpointRegistry.baseUrl);
      expect(ApiEndpoints.login, ApiEndpointRegistry.login);
    });
  });

  group('ApiService endpoint usage', () {
    test(
      'product requests use the saved access token as a bearer token',
      () async {
        final api = ApiService()..setAccessToken('test-token');
        String? authorization;
        api.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              authorization = options.headers['Authorization'] as String?;
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'products': [], 'total': 0},
                ),
              );
            },
          ),
        );
        await api.products(0, '');
        expect(authorization, 'Bearer test-token');
      },
    );

    test('login uses registered login endpoint', () async {
      final api = ApiService();
      String? requestedPath;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'accessToken': 'access', 'refreshToken': 'refresh'},
              ),
            );
          },
        ),
      );
      final result = await api.login('user', 'pass');
      expect(requestedPath, ApiEndpointRegistry.login);
      expect(result['accessToken'], 'access');
    });

    test('refresh uses registered refresh endpoint', () async {
      final api = ApiService();
      String? requestedPath;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'accessToken': 'new-access'},
              ),
            );
          },
        ),
      );
      final result = await api.refresh('old-refresh');
      expect(requestedPath, ApiEndpointRegistry.refresh);
      expect(result['accessToken'], 'new-access');
    });

    test('products search query uses registered search endpoint', () async {
      final api = ApiService();
      String? requestedPath;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'products': [], 'total': 0},
              ),
            );
          },
        ),
      );
      await api.products(0, 'phone');
      expect(requestedPath, ApiEndpointRegistry.productSearch);
    });

    test('product detail uses registered product detail endpoint', () async {
      final api = ApiService();
      String? requestedPath;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 12,
                  'title': 'Test Item',
                  'price': 25,
                  'rating': 4.5,
                  'category': 'test',
                  'description': 'desc',
                  'thumbnail': 'thumb',
                  'images': <dynamic>[],
                },
              ),
            );
          },
        ),
      );
      final product = await api.product(12);
      expect(requestedPath, ApiEndpointRegistry.productDetail(12));
      expect(product.id, 12);
      expect(product.title, 'Test Item');
    });
  });

  group('Dev logging', () {
    test('logs api base url, status code, and response on successful calls', () async {
      final logs = <String>[];
      final api = ApiService(logHandler: logs.add);

      api.dio.httpClientAdapter = _MockAdapter(
        200,
        '{"products": [], "total": 0}',
      );

      await api.products(0, '');

      // Verify request log
      final requestLog = logs.firstWhere((log) => log.contains('[API Request]'));
      expect(requestLog, contains('API Base URL: https://dummyjson.com'));
      expect(requestLog, contains('Endpoint: /products'));

      // Verify response log contains base url, status code, and response
      final responseLog = logs.firstWhere((log) => log.contains('[API Response]'));
      expect(responseLog, contains('API Base URL: https://dummyjson.com'));
      expect(responseLog, contains('Status Code: 200'));
      expect(responseLog, contains('Response: {products: [], total: 0}'));
    });

    test('logs api base url, status code, and response on error calls', () async {
      final logs = <String>[];
      final api = ApiService(logHandler: logs.add);

      api.dio.httpClientAdapter = _MockAdapter(
        404,
        '{"message": "Product not found"}',
      );

      await expectLater(
        () => api.product(999),
        throwsA(isA<DioException>()),
      );

      final errorLog = logs.firstWhere((log) => log.contains('[API Error]'));
      expect(errorLog, contains('API Base URL: https://dummyjson.com'));
      expect(errorLog, contains('Status Code: 404'));
      expect(errorLog, contains('Response: {message: Product not found}'));
    });
  });
}
