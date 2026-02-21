import 'package:flutter/material.dart';

/// BuildContext extensions (theme, media, navigation).
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
}
