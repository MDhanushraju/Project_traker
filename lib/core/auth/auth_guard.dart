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

    // Not logged in → only login allowed
    if (user == null) {
      if (routeName == AppRoutes.login) return const GuardResult.allow();
      return const GuardResult.redirect(AppRoutes.login);
    }

    // Logged in: visiting login → redirect to default home by role
    if (routeName == AppRoutes.login) {
      return GuardResult.redirect(user.defaultRoute);
    }

    // Logged in: check role can access this route via RoleAccess
    if (RoleAccess.canAccessRoute(user.role, routeName)) {
      return const GuardResult.allow();
    }
    return GuardResult.redirect(user.defaultRoute);
  }
}
