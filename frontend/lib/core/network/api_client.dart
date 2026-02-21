import 'package:dio/dio.dart';

import '../../app/app_config.dart';
import '../auth/token_manager.dart';

/// HTTP client for API calls. Adds auth token to requests.
class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.instance.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<dynamic> get(String path) async {
    final r = await _dio.get(path);
    return r.data;
  }

  Future<Map<String, dynamic>> post(String path, [dynamic data]) async {
    final r = await _dio.post<Map<String, dynamic>>(path, data: data);
    return r.data ?? {};
  }

  Future<dynamic> patch(String path, [dynamic data]) async {
    final r = await _dio.patch(path, data: data);
    return r.data;
  }

  Future<void> delete(String path) async {
    await _dio.delete(path);
  }
}
