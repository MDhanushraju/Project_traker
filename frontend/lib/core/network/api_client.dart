import 'package:dio/dio.dart';

import '../../app/app_config.dart';
import '../auth/token_manager.dart';
import 'api_config.dart';

/// HTTP client for API calls. Adds auth token to requests.
/// When [apisHandicapped] is true, no network calls are made; mock/empty data is returned.
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
        options.baseUrl = AppConfig.apiBaseUrl;
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

  Future<dynamic> get(String path, [Map<String, dynamic>? queryParameters]) async {
    if (apisHandicapped) return _handicappedGet(path);
    final r = await _dio.get(path, queryParameters: queryParameters);
    return r.data;
  }

  Future<Map<String, dynamic>> post(String path, [dynamic data]) async {
    if (apisHandicapped) return _handicappedPost(path);
    final r = await _dio.post<Map<String, dynamic>>(path, data: data);
    return r.data ?? {};
  }

  Future<dynamic> patch(String path, [dynamic data]) async {
    if (apisHandicapped) return _handicappedPatch(path);
    final r = await _dio.patch(path, data: data);
    return r.data;
  }

  Future<void> delete(String path) async {
    if (apisHandicapped) return;
    await _dio.delete(path);
  }

  dynamic _handicappedGet(String path) {
    if (path.contains('projects') && !path.contains('users')) return <Map<String, dynamic>>[];
    if (path.contains('tasks')) return <Map<String, dynamic>>[];
    if (path.contains('/api/users')) {
      if (path.contains('team-manager')) return <String, String>{};
      if (path.contains('team-members')) return <String, dynamic>{};
      if (path.contains('team-leader') || path.contains('member')) return <dynamic>[];
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _handicappedPost(String path) => {};
  dynamic _handicappedPatch(String path) => null;
}
