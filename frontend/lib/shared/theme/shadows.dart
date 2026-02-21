import 'package:flutter/material.dart';

/// Soft, Apple-style shadows. Use via theme (e.g. cardTheme) or for custom elevation.
/// No hardcoded colors in widgets; shadows use black with low opacity.
class AppShadows {
  AppShadows._();

  static const Color _shadowColor = Color(0x15000000);

  /// Subtle shadow for cards and surfaces (Apple-style soft).
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: _shadowColor,
      blurRadius: 10,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Medium elevation for raised elements (e.g. FAB, dropdowns).
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Slightly stronger for modals or floating panels.
  static const List<BoxShadow> strong = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}
