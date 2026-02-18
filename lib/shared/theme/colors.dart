import 'package:flutter/material.dart';

/// Single source for app color. Change [seedColor] once to update the whole app.
/// Feature widgets must NOT use this file for raw colors; use Theme.of(context).colorScheme.
///
/// Checkpoint: Change [seedColor] (e.g. to 0xFF34C759 for green) and hot restart — whole app updates.
class AppColors {
  AppColors._();

  /// Seed color for ColorScheme.fromSeed. Only referenced in [AppTheme].
  static const Color seedColor = Color(0xFF007AFF); // Apple-style blue

  /// Neutrals for surfaces/shadows when not using scheme.
  static const Color neutralLight = Color(0xFFF5F5F7);
  static const Color neutralDark = Color(0xFF1C1C1E);
}
