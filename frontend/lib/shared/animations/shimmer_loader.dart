import 'package:flutter/material.dart';

/// Shimmer loading placeholder. Uses theme.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    this.width,
    this.height = 16,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
