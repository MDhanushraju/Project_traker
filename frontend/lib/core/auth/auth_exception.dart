/// Thrown when auth API fails (invalid credentials, email exists, etc).
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
