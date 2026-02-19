import '../core/auth/auth_service.dart';
import '../core/theme/theme_mode_state.dart';

/// Runs one-time app setup before [runApp].
/// Restores auth session and theme preference.
class AppInitializer {
  AppInitializer._();

  /// Call before [runApp]. Restores session (token + role) and theme mode.
  static Future<void> init() async {
    await Future.wait([
      AuthService.instance.restoreSession(),
      ThemeModeState.load(),
    ]);
  }
}
