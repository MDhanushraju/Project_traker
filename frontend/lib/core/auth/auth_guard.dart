import 'auth_state.dart';
import 'role_access.dart';
import '../../app/app_routes.dart';

/// Result of a guard check: allow the route or redirect to another.
class GuardResult {
  const GuardResult.allow() : redirectTo = null;
  const GuardResult.redirect(String this.redirectTo);

  final String? redirectTo;
  bool get allowed => redirectTo == null;
}

/// Protects routes by auth and role. Uses [RoleAccess] only; no hardcoded role logic here.
class AuthGuard {
  AuthGuard._();

  static GuardResult check(String routeName, AuthState auth) {
    final user = auth.currentUser;

    // Not logged in → sign-up, login, login-form, forgot-password flow allowed
    if (user == null) {
      if (routeName == AppRoutes.signUp ||
          routeName == AppRoutes.login ||
          routeName == AppRoutes.loginForm ||
          routeName == AppRoutes.forgotPassword ||
          routeName == AppRoutes.forgotPasswordOtp ||
          routeName == AppRoutes.resetPassword) {
        return const GuardResult.allow();
      }
      return const GuardResult.redirect(AppRoutes.loginForm);
    }

    // Logged in: visiting auth pages → redirect to default home by role
    if (routeName == AppRoutes.signUp ||
        routeName == AppRoutes.login ||
        routeName == AppRoutes.loginForm ||
        routeName == AppRoutes.forgotPassword ||
        routeName == AppRoutes.forgotPasswordOtp ||
        routeName == AppRoutes.resetPassword) {
      return GuardResult.redirect(user.defaultRoute);
    }

    // Logged in: check role can access this route via RoleAccess
    if (RoleAccess.canAccessRoute(user.role, routeName)) {
      return const GuardResult.allow();
    }
    return GuardResult.redirect(user.defaultRoute);
  }
}
