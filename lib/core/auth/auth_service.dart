import '../constants/roles.dart';
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

  /// Login with email/password. Calls API, stores JWT + role, updates auth state.
  /// Replace mock with real [ApiClient] when backend is ready.
  Future<void> login(String email, String password) async {
    final response = await _loginApi(email, password);
    final token = response['token'] as String?;
    final roleStr = response['role'] as String?;
    if (token == null || roleStr == null) return;

    await _tokens.setToken(token);
    await _tokens.setStoredRole(roleStr);
    final role = _parseRole(roleStr);
    if (role != null) _auth.login(role);
  }

  /// Sign up with name, email, password, id card, and role. Stores token + role like login.
  /// Replace with real API when backend is ready.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    String? idCardNumber,
    required AppRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final token = _mockTokenForRole(role);
    await _tokens.setToken(token);
    await _tokens.setStoredRole(role.name);
    _auth.login(role, displayName: fullName.isNotEmpty ? fullName : null);
  }

  /// Demo: login as role and persist (same flow as [login] but with mock token).
  /// UI uses this for role picker; token is still stored so refresh keeps session.
  Future<void> loginWithRole(AppRole role) async {
    final token = _mockTokenForRole(role);
    await _tokens.setToken(token);
    await _tokens.setStoredRole(role.name);
    _auth.login(role);
  }

  /// Logout: clear storage and auth state.
  Future<void> logout() async {
    await _tokens.clear();
    _auth.logout();
  }

  /// Mock API call. Replace with real API (e.g. [ApiClient.post] to [ApiEndpoints.login]).
  Future<Map<String, dynamic>> _loginApi(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Demo: accept any and return admin. Replace with real API.
    return {'token': _mockTokenForRole(AppRole.admin), 'role': 'admin'};
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
