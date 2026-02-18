import 'package:flutter/material.dart';

/// Forgot password screen. Add route in [AppRoutes] when ready.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: const Center(child: Text('Forgot Password')),
    );
  }
}
