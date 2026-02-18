import 'token_storage.dart';

/// Handles JWT and role persistence. UI must NEVER touch storage directly — use [AuthService] only.
/// Web → localStorage. Mobile/iOS → secure storage (via [TokenStorage]).
class TokenManager {
  TokenManager._() : _storage = createTokenStorage();

  static final TokenManager instance = TokenManager._();

  final TokenStorage _storage;

  static const String _keyToken = 'auth_token';
  static const String _keyRole = 'auth_role';

  Future<String?> getToken() => _storage.get(_keyToken);

  Future<void> setToken(String token) => _storage.set(_keyToken, token);

  /// Stored role name for session restore (e.g. 'admin', 'manager', 'member').
  Future<String?> getStoredRole() => _storage.get(_keyRole);

  Future<void> setStoredRole(String role) => _storage.set(_keyRole, role);

  Future<void> clear() async {
    await _storage.remove(_keyToken);
    await _storage.remove(_keyRole);
  }
}
