import '../core/auth/auth_service.dart';

/// Runs one-time app setup before [runApp].
/// Restores auth session so refresh keeps user logged in.
class AppInitializer {
  AppInitializer._();

  /// Call before [runApp]. Restores session from storage (token + role).
  static Future<void> init() async {
    await AuthService.instance.restoreSession();
  }
}
