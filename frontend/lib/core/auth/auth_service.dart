import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants/roles.dart';
import 'auth_exception.dart';
import '../../app/app_config.dart';
import '../network/api_config.dart';
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
  /// Backend may return empty token; we restore by stored role when present.
  Future<void> restoreSession() async {
    final roleStr = await _tokens.getStoredRole();
    if (roleStr != null && roleStr.isNotEmpty) {
      final role = _parseRole(roleStr);
      if (role != null) {
        _auth.login(role);
      }
    }
  }

  /// Login with email or 5-digit ID number + password. Calls API, stores JWT + role, updates auth state.
  /// [emailOrId] can be an email address or the 5-digit login ID.
  /// When [apisHandicapped], uses [useRoleForMock] to log in as UI-only (no API call).
  Future<void> login(String emailOrId, String password, {String? idCardNumber, AppRole? useRoleForMock}) async {
    if (apisHandicapped) {
      final role = useRoleForMock ?? AppRole.member;
      await _tokens.setToken(_mockTokenForRole(role));
      await _tokens.setStoredRole(role.name);
      _auth.login(role);
      return;
    }
    final response = await _loginApi(emailOrId, password, idCardNumber: idCardNumber);
    final token = response['token'] as String? ?? '';
    final roleStr = response['role'] as String?;
    if (roleStr == null || roleStr.isEmpty) return;

    await _tokens.setToken(token);
    await _tokens.setStoredRole(roleStr);
    final role = _parseRole(roleStr);
    final displayName = response['fullName']?.toString();
    if (role != null) _auth.login(role, displayName: displayName);
  }

  /// Sign up via API. On success returns user info including [loginId] (5-digit ID).
  /// Does NOT auto-login; user must go to login.
  /// Throws [AuthException] on API error (email exists, validation failed, etc).
  /// [position] is required for teamLeader and member (e.g. Developer, Tester).
  Future<Map<String, dynamic>?> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    String? idCardNumber,
    required AppRole role,
    String? position,
  }) async {
    if (apisHandicapped) return null; // UI-only: pretend signup succeeded, no API call.
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ));
      final body = <String, dynamic>{
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role.name,
      };
      if (idCardNumber != null && idCardNumber.trim().isNotEmpty) {
        body['idCardNumber'] = idCardNumber.trim();
      }
      if (position != null && position.trim().isNotEmpty) {
        body['position'] = position.trim();
      }
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/signup',
        data: jsonEncode(body),
        options: Options(contentType: Headers.jsonContentType, responseType: ResponseType.json),
      );
      final data = res.data;
      if (data == null || data['success'] != true) {
        throw AuthException(_extractErrorMessage(data, 'Sign up failed'));
      }
      final d = data['data'] as Map<String, dynamic>?;
      return d;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = responseData is Map<String, dynamic>
          ? _extractErrorMessage(responseData, e.message ?? 'Sign up failed')
          : (responseData is String && responseData.isNotEmpty)
              ? responseData
              : (e.message ?? 'Sign up failed');
      throw AuthException(msg);
    }
  }

  /// Login as role (calls backend /api/auth/login-with-role).
  /// When [apisHandicapped], logs in with mock token (UI-only).
  Future<void> loginWithRole(AppRole role) async {
    if (apisHandicapped) {
      await _tokens.setToken(_mockTokenForRole(role));
      await _tokens.setStoredRole(role.name);
      _auth.login(role);
      return;
    }
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
    // Fallback: mock token for offline/demo (only when APIs not handicapped)
    await _tokens.setToken(_mockTokenForRole(role));
    await _tokens.setStoredRole(role.name);
    _auth.login(role);
  }

  Future<Map<String, dynamic>?> _loginWithRoleApi(AppRole role) async {
    if (apisHandicapped) return null;
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
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

  /// Login with email or 5-digit ID + password. Calls real API.
  /// Sends loginId (int) if [emailOrId] is a 5-digit number, else sends email.
  Future<Map<String, dynamic>> _loginApi(String emailOrId, String password, {String? idCardNumber}) async {
    if (apisHandicapped) throw AuthException('APIs are disabled. Login and signup are not available.');
    final trimmed = emailOrId.trim();
    if (trimmed.isEmpty) throw AuthException('Email or ID number is required');
    if (password.isEmpty) throw AuthException('Password is required');
    if (password.trim().isEmpty) throw AuthException('Password cannot be only spaces');
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ));
      final payload = <String, dynamic>{'password': password};
      final loginId = int.tryParse(trimmed);
      if (loginId != null && trimmed.length == 5 && loginId >= 10000 && loginId <= 99999) {
        payload['loginId'] = loginId;
      } else {
        payload['email'] = trimmed;
      }
      if (idCardNumber != null && idCardNumber.trim().isNotEmpty) {
        payload['idCardNumber'] = idCardNumber.trim();
      }
      final res = await dio.post<Map<String, dynamic>>('/api/auth/login', data: payload);
      final data = res.data;
      if (data == null || data['success'] != true) {
        throw AuthException(_extractErrorMessage(data, 'Login failed'));
      }
      final d = data['data'] as Map<String, dynamic>?;
      if (d == null) throw AuthException('Invalid response');
      return d;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = responseData is Map
          ? _extractErrorMessage(responseData as Map<String, dynamic>, e.message ?? 'Login failed')
          : (e.message ?? 'Login failed');
      throw AuthException(msg);
    }
  }

  /// Build a single error message from API response (message + optional errors map).
  /// Backend sends validation errors in "data"; some APIs use "errors".
  String _extractErrorMessage(Map<String, dynamic>? data, String fallback) {
    if (data == null) return fallback;
    final message = data['message']?.toString();
    final errors = data['errors'] ?? data['data'];
    if (errors is Map<String, dynamic>) {
      final parts = <String>[];
      if (message != null && message.isNotEmpty) parts.add(message);
      for (final entry in errors.entries) {
        final val = entry.value?.toString();
        if (val != null && val.isNotEmpty) parts.add('${entry.key}: $val');
      }
      if (parts.isNotEmpty) return parts.join(' ');
    }
    return (message != null && message.isNotEmpty) ? message : fallback;
  }

  String _mockTokenForRole(AppRole role) {
    return 'mock_jwt_${role.name}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Backend returns role as lowercase, with underscore for team_leader. Dart enum is camelCase (teamLeader).
  AppRole? _parseRole(String name) {
    if (name.isEmpty) return null;
    final normalized = name.trim().toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'admin': return AppRole.admin;
      case 'manager': return AppRole.manager;
      case 'member': return AppRole.member;
      case 'team_leader': return AppRole.teamLeader;
      default: return null;
    }
  }
}
