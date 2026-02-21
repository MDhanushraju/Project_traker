import 'package:flutter/material.dart';

/// Dashboard progress indicator widget (named to avoid clash with Flutter's ProgressIndicator).
class DashboardProgressIndicator extends StatelessWidget {
  const DashboardProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
