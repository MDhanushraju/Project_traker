import 'package:flutter/material.dart';

import 'app_config.dart';
import 'app_routes.dart';
import 'app_theme.dart';
import '../core/theme/theme_mode_state.dart';
import '../core/auth/auth_guard.dart';
import '../core/auth/auth_state.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/login_form_page.dart';
import '../modules/auth/sign_up_page.dart';
import '../modules/auth/forgot_password_page.dart';
import '../modules/auth/forgot_password_otp_page.dart';
import '../modules/auth/reset_password_page.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/projects/project_list_page.dart';
import '../modules/tasks/task_list_page.dart';
import '../modules/settings/settings_page.dart';

/// All known route names. Unknown routes are redirected.
const Set<String> _kKnownRoutes = {
  AppRoutes.signUp,
  AppRoutes.login,
  AppRoutes.loginForm,
  AppRoutes.forgotPassword,
  AppRoutes.forgotPasswordOtp,
  AppRoutes.resetPassword,
  AppRoutes.dashboard,
  AppRoutes.projects,
  AppRoutes.tasks,
  AppRoutes.settings,
};

/// Root widget. MaterialApp with theme and guarded routes.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    AuthState.instance.addListener(_onAuthChanged);
    ThemeModeState.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AuthState.instance.removeListener(_onAuthChanged);
    ThemeModeState.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onAuthChanged() => setState(() {});
  void _onThemeChanged() => setState(() {});

  static Widget _buildPage(String routeName) {
    switch (routeName) {
      case AppRoutes.signUp:
        return const SignUpPage();
      case AppRoutes.login:
        return const LoginPage();
      case AppRoutes.loginForm:
        return const LoginFormPage();
      case AppRoutes.forgotPassword:
        return const ForgotPasswordPage();
      case AppRoutes.forgotPasswordOtp:
        return const ForgotPasswordOtpPage();
      case AppRoutes.resetPassword:
        return const ResetPasswordPage();
      case AppRoutes.dashboard:
        return const DashboardPage();
      case AppRoutes.projects:
        return const ProjectListPage();
      case AppRoutes.tasks:
        return const TaskListPage();
      case AppRoutes.settings:
        return const SettingsPage();
      default:
        return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeModeState.instance.themeMode,
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        final name = settings.name ?? AppRoutes.login;
        final effectiveRoute =
            _kKnownRoutes.contains(name) ? name : AppRoutes.login;
        final result = AuthGuard.check(effectiveRoute, AuthState.instance);

        if (result.allowed) {
          return MaterialPageRoute<void>(
            settings: RouteSettings(
              name: effectiveRoute,
              arguments: settings.arguments,
            ),
            builder: (_) => _buildPage(effectiveRoute),
          );
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => _Redirect(routeName: result.redirectTo!),
        );
      },
    );
  }
}

/// One-frame widget that replaces current route with the guarded redirect target.
class _Redirect extends StatefulWidget {
  const _Redirect({required this.routeName});

  final String routeName;

  @override
  State<_Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<_Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(widget.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Loading…',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
