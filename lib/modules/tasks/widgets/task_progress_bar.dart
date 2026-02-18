import 'package:flutter/material.dart';

/// Progress bar for task completion. Uses theme.
class TaskProgressBar extends StatelessWidget {
  const TaskProgressBar({super.key, this.progress = 0.0});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: progress.clamp(0.0, 1.0));
  }
}
