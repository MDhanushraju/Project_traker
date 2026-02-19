import 'package:flutter/material.dart';

import '../../../core/constants/roles.dart';
import '../../../core/auth/role_access.dart';
import '../../../app/app_routes.dart';
import 'auth_theme.dart';

/// Welcome to Taker role selection screen. First page when opening the app.
/// Responsive: different layout for web vs mobile.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _onRoleSelected(AppRole role) {
    Navigator.of(context).pushNamed(
      AppRoutes.loginForm,
      arguments: role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AuthLayout.isMobile(context);

    return Scaffold(
        backgroundColor: AuthTheme.background(context),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AuthLayout.horizontalPadding(context),
                vertical: isMobile ? 16 : 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AuthLayout.maxFormWidth(context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Taker',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AuthTheme.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            // TODO: Show help / onboarding
                          },
                          icon: const Icon(Icons.help_outline),
                          color: AuthTheme.textSecondary(context),
                          style: IconButton.styleFrom(
                            backgroundColor: AuthTheme.textPrimary(context).withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 24 : 32),
                    Text(
                      'Welcome to Taker',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AuthTheme.textPrimary(context),
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your role to continue to your dashboard',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AuthTheme.textSecondary(context),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 24 : 32),
                    for (final role in AppRole.values)
                      _RoleCard(
                        role: role,
                        onTap: () => _onRoleSelected(role),
                      ),
                    SizedBox(height: isMobile ? 32 : 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'First time?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AuthTheme.textSecondary(context),
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.signUp);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AuthTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Sign up here'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.onTap,
  });

  final AppRole role;
  final VoidCallback onTap;

  IconData get _icon {
    switch (role) {
      case AppRole.admin:
        return Icons.shield_outlined;
      case AppRole.manager:
        return Icons.dashboard_outlined;
      case AppRole.member:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AuthLayout.isMobile(context);

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      elevation: 0,
      color: AuthTheme.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Row(
            children: [
              Icon(_icon, color: AuthTheme.primaryBlue, size: isMobile ? 24 : 28),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      role.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AuthTheme.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      RoleAccess.descriptionForRole(role),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AuthTheme.textSecondary(context),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AuthTheme.textSecondary(context)),
            ],
          ),
        ),
      ),
    );
  }
}
