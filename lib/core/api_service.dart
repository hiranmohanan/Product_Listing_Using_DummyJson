import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'product.dart';

/// Registry containing all static API endpoints and URLs.
class ApiEndpointRegistry {
  ApiEndpointRegistry._();

  static const String baseUrl = 'https://dummyjson.com';
  static const String authPrefix = '/auth/';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String products = '/products';
  static const String productSearch = '/products/search';

  static String productDetail(int id) => '$products/$id';
  static String product(int id) => productDetail(id);

  static bool isAuthPath(String path) => path.startsWith(authPrefix);
}

typedef ApiEndpoints = ApiEndpointRegistry;

/// Interceptor that emits dev logs for all API calls, including
/// API base URL, status code, and response data.
class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor([void Function(String message)? logger])
      : _logger = logger ?? ApiService.defaultLogHandler;

  final void Function(String message) _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger(
      '[API Request] ${options.method} ${options.uri}\n'
      'API Base URL: ${options.baseUrl}\n'
      'Endpoint: ${options.path}\n'
      'Headers: ${options.headers}\n'
      'Query: ${options.queryParameters}\n'
      'Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger(
      '[API Response] ${response.requestOptions.method} ${response.requestOptions.uri}\n'
      'API Base URL: ${response.requestOptions.baseUrl}\n'
      'Status Code: ${response.statusCode ?? 'unknown'}\n'
      'Response: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger(
      '[API Error] ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      'API Base URL: ${err.requestOptions.baseUrl}\n'
      'Endpoint: ${err.requestOptions.path}\n'
      'Status Code: ${err.response?.statusCode ?? 'N/A'}\n'
      'Response: ${err.response?.data ?? err.message}',
    );
    handler.next(err);
  }
}

class ApiService {
  ApiService({Dio? dio, void Function(String message)? logHandler})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpointRegistry.baseUrl,
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
              ),
            ) {
    final logger = logHandler ?? defaultLogHandler;
    this.dio.interceptors.add(ApiLogInterceptor(logger));
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null &&
              !ApiEndpointRegistry.isAuthPath(options.path)) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          if (error.response?.statusCode != 401 ||
              ApiEndpointRegistry.isAuthPath(request.path) ||
              request.extra['authRetried'] == true ||
              onUnauthorized == null) {
            handler.next(error);
            return;
          }
          try {
            final token = await onUnauthorized!();
            if (token == null) {
              handler.next(error);
              return;
            }
            request.extra['authRetried'] = true;
            request.headers['Authorization'] = 'Bearer $token';
            handler.resolve(await this.dio.fetch(request));
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );
  }

  static void defaultLogHandler(String message) {
    developer.log(message, name: 'ApiService');
  }

  final Dio dio;
  String? _accessToken;
  Future<String?> Function()? onUnauthorized;

  void setAccessToken(String? token) => _accessToken = token;

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await dio.post(
      ApiEndpointRegistry.login,
      data: {'username': username, 'password': password},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await dio.post(
      ApiEndpointRegistry.refresh,
      data: {'refreshToken': refreshToken},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<ProductPage> products(int skip, String query) async {
    final response = await dio.get(
      query.isEmpty
          ? ApiEndpointRegistry.products
          : ApiEndpointRegistry.productSearch,
      queryParameters: {
        if (query.isNotEmpty) 'q': query,
        'limit': 20,
        'skip': skip,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final products = (data['products'] as List<dynamic>? ?? const [])
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    return ProductPage(products, (data['total'] as num?)?.toInt() ?? 0);
  }

  Future<Product> product(int id) async {
    final response = await dio.get(ApiEndpointRegistry.productDetail(id));
    return Product.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}

bool isConnectionFailure(Object error) {
  if (error is! DioException) return false;
  return error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout;
}
