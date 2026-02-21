import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyThemeMode = 'theme_mode';

/// Manages app theme mode (light, dark, system) with persistence.
class ThemeModeState extends ChangeNotifier {
  ThemeModeState._();
  static final ThemeModeState instance = ThemeModeState._();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// Initialize from storage. Call before [runApp].
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyThemeMode);
    if (index != null && index >= 0 && index <= 2) {
      instance._themeMode = ThemeMode.values[index];
    }
  }

  /// Update theme mode and persist.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  /// Cycle: system -> light -> dark -> system
  Future<void> cycle() async {
    final next = ThemeMode.values[(_themeMode.index + 1) % 3];
    await setThemeMode(next);
  }
}
