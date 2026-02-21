import 'package:dio/dio.dart';

import '../constants/roles.dart';
import 'auth_exception.dart';
import '../../app/app_config.dart';
import 'auth_state.dart';
import 'token_manager.dart';

/// Handles login, logout, and session restore. UI must NEVER touch [TokenManager] or storage directly.
///
/// Flow: Login → API call → Receive JWT → Store token (via [TokenManager]) → Update [AuthState] → Redirect.
/// On app start, [restoreSession] runs so refresh keeps user logged in.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final AuthState _auth = AuthState.instance;
  final TokenManager _tokens = TokenManager.instance;

  bool get isLoggedIn => _auth.isLoggedIn;
  AppRole? get role => _auth.role;

  /// Restore session from storage. Call from [AppInitializer] before [runApp].
  /// Checkpoint: after this, refresh page → stays logged in.
  Future<void> restoreSession() async {
    final token = await _tokens.getToken();
    final roleStr = await _tokens.getStoredRole();
    if (token != null && token.isNotEmpty && roleStr != null) {
      final role = _parseRole(roleStr);
      if (role != null) {
        _auth.login(role);
      }
    }
  }

  /// Login with email + password (optionally idCardNumber). Calls API, stores JWT + role, updates auth state.
  Future<void> login(String email, String password, {String? idCardNumber}) async {
    final response = await _loginApi(email, password, idCardNumber: idCardNumber);
    final token = response['token'] as String?;
    final roleStr = response['role'] as String?;
    if (token == null || roleStr == null) return;

    await _tokens.setToken(token);
    await _tokens.setStoredRole(roleStr);
    final role = _parseRole(roleStr);
    if (role != null) _auth.login(role);
  }

  /// Sign up via API. On success, does NOT auto-login; user must go to login.
  /// Throws [AuthException] on API error (email exists, validation failed, etc).
  /// [position] is required for teamLeader and member (e.g. Developer, Tester).
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    String? idCardNumber,
    required AppRole role,
    String? position,
  }) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/signup',
        data: {
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'confirmPassword': confirmPassword,
          if (idCardNumber != null && idCardNumber.trim().isNotEmpty) 'idCardNumber': idCardNumber.trim(),
          'role': role.name,
          if (position != null && position.trim().isNotEmpty) 'position': position.trim(),
        },
      );
      final data = res.data;
      if (data == null || data['success'] != true) {
        throw AuthException((data?['message'] ?? 'Sign up failed').toString());
      }
    } on DioException catch (e) {
      final msg = (e.response?.data is Map ? (e.response!.data as Map)['message'] : null)?.toString() ??
          e.message ??
          'Sign up failed';
      throw AuthException(msg);
    }
  }

  /// Login as role (calls backend /api/auth/login-with-role).
  /// Falls back to mock token if API fails (offline/demo).
  Future<void> loginWithRole(AppRole role) async {
    try {
      final res = await _loginWithRoleApi(role);
      if (res != null && res['token'] != null) {
        await _tokens.setToken(res['token'] as String);
        final roleStr = (res['role'] ?? role.name).toString();
        await _tokens.setStoredRole(roleStr);
        final parsedRole = _parseRole(roleStr) ?? role;
        _auth.login(parsedRole, displayName: res['fullName']?.toString());
        return;
      }
    } catch (_) {}
    // Fallback: mock token for offline/demo
    await _tokens.setToken(_mockTokenForRole(role));
    await _tokens.setStoredRole(role.name);
    _auth.login(role);
  }

  Future<Map<String, dynamic>?> _loginWithRoleApi(AppRole role) async {
    final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    final r = await dio.post<Map<String, dynamic>>('/api/auth/login-with-role', data: {'role': role.name});
    final data = r.data;
    if (data != null && data['success'] == true && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    }
    return null;
  }

  /// Logout: clear storage and auth state.
  Future<void> logout() async {
    await _tokens.clear();
    _auth.logout();
  }

  /// Login with email + password (optionally idCardNumber). Calls real API.
  Future<Map<String, dynamic>> _loginApi(String email, String password, {String? idCardNumber}) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      final payload = <String, dynamic>{
        'email': email.trim(),
        'password': password,
      };
      if (idCardNumber != null && idCardNumber.trim().isNotEmpty) {
        payload['idCardNumber'] = idCardNumber.trim();
      }
      final res = await dio.post<Map<String, dynamic>>('/api/auth/login', data: payload);
      final data = res.data;
      if (data == null || data['success'] != true) {
        throw AuthException((data?['message'] ?? 'Login failed').toString());
      }
      final d = data['data'] as Map<String, dynamic>?;
      if (d == null) throw AuthException('Invalid response');
      return d;
    } on DioException catch (e) {
      final msg = (e.response?.data is Map ? (e.response!.data as Map)['message'] : null)?.toString() ??
          e.message ??
          'Login failed';
      throw AuthException(msg);
    }
  }

  String _mockTokenForRole(AppRole role) {
    return 'mock_jwt_${role.name}_${DateTime.now().millisecondsSinceEpoch}';
  }

  AppRole? _parseRole(String name) {
    for (final r in AppRole.values) {
      if (r.name == name) return r;
    }
    return null;
  }
}
