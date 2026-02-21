import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Shared theme colors for auth pages. Supports light and dark mode.
class AuthTheme {
  AuthTheme._();

  // Dark mode
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color cardBackgroundDark = Color(0xFF161B22);
  static const Color primaryBlue = Color(0xFF58A6FF);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF8B949E);

  // Light mode
  static const Color backgroundLight = Color(0xFFF0F2F5);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);

  /// Colors based on current theme brightness.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? backgroundDark : backgroundLight;
  static Color cardBackground(BuildContext context) =>
      isDark(context) ? cardBackgroundDark : cardBackgroundLight;
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? textPrimaryDark : const Color(0xFF1C1C1E);
  static Color textSecondary(BuildContext context) =>
      isDark(context) ? textSecondaryDark : const Color(0xFF6E6E73);
}

/// Responsive breakpoints and helpers for web vs mobile.
class AuthLayout {
  AuthLayout._();

  /// Mobile breakpoint (px).
  static const double mobileBreakpoint = 600;

  static bool get isWeb => kIsWeb;

  /// True if screen width < breakpoint (mobile-like).
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }

  /// True if screen width >= breakpoint (desktop/tablet).
  static bool isDesktop(BuildContext context) {
    return !isMobile(context);
  }

  /// Max content width for auth forms.
  static double maxFormWidth(BuildContext context) {
    return isMobile(context) ? double.infinity : 420;
  }

  /// Horizontal padding.
  static double horizontalPadding(BuildContext context) {
    return isMobile(context) ? 20 : 32;
  }

  /// Card padding.
  static double cardPadding(BuildContext context) {
    return isMobile(context) ? 20 : 32;
  }
}
