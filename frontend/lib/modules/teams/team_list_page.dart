import 'package:flutter/material.dart';

/// Team list screen. Add route and MainLayout when needed.
class TeamListPage extends StatelessWidget {
  const TeamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: const Center(child: Text('Teams')),
    );
  }
}
