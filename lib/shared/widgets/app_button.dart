import 'package:flutter/material.dart';

/// Primary button. Uses theme; no hardcoded colors.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(label);
    switch (variant) {
      case AppButtonVariant.filled:
        return icon != null
            ? FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 20),
                label: labelWidget,
              )
            : FilledButton(onPressed: onPressed, child: labelWidget);
      case AppButtonVariant.outlined:
        return icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 20),
                label: labelWidget,
              )
            : OutlinedButton(onPressed: onPressed, child: labelWidget);
      case AppButtonVariant.text:
        return icon != null
            ? TextButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 20),
                label: labelWidget,
              )
            : TextButton(onPressed: onPressed, child: labelWidget);
    }
  }
}

enum AppButtonVariant { filled, outlined, text }
