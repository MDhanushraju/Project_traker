import 'package:flutter/material.dart';

/// Slide-in animation wrapper.
class SlideIn extends StatelessWidget {
  const SlideIn({
    super.key,
    required this.child,
    this.offset = const Offset(0, 20),
    this.duration = const Duration(milliseconds: 300),
  });

  final Widget child;
  final Offset offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: offset, end: Offset.zero),
      duration: duration,
      builder: (context, value, child) => Transform.translate(
        offset: value,
        child: child,
      ),
      child: child,
    );
  }
}
