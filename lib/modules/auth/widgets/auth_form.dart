import 'package:flutter/material.dart';

/// Reusable auth form (email + password). Use in [LoginPage] when wiring real API.
class AuthForm extends StatelessWidget {
  const AuthForm({
    super.key,
    this.onSubmit,
  });

  final void Function(String email, String password)? onSubmit;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Auth form placeholder'),
      ],
    );
  }
}
