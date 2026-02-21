import 'package:flutter/material.dart';

/// Fade-in animation wrapper.
class FadeIn extends StatelessWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
