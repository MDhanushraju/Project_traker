import '../constants/roles.dart';
import '../../app/app_routes.dart';

/// Single source of truth for route–role access. Use this instead of hardcoding roles in UI.
/// [AuthGuard] and nav UI both rely on this.
class RoleAccess {
  RoleAccess._();

  /// Routes that require authentication (all except login).
  static const Set<String> protectedRoutes = {
    AppRoutes.dashboard,
    AppRoutes.projects,
    AppRoutes.tasks,
    AppRoutes.settings,
  };

  /// Public route; no role required.
  static const String publicRoute = AppRoutes.login;

  /// Default route after login for each role.
  static String defaultRouteForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
      case AppRole.manager:
        return AppRoutes.dashboard;
      case AppRole.member:
        return AppRoutes.tasks;
    }
  }

  /// Routes the given role is allowed to access (for nav links, no hardcoded role checks in UI).
  static List<String> allowedRoutesForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return [AppRoutes.dashboard, AppRoutes.projects, AppRoutes.tasks, AppRoutes.settings];
      case AppRole.manager:
        return [AppRoutes.dashboard, AppRoutes.projects, AppRoutes.tasks, AppRoutes.settings];
      case AppRole.member:
        return [AppRoutes.tasks];
    }
  }

  /// Whether [role] can access [routeName]. Used by [AuthGuard] only.
  static bool canAccessRoute(AppRole? role, String routeName) {
    if (role == null) return false;
    return allowedRoutesForRole(role).contains(routeName);
  }

  /// Human-readable description of what each role can access (for login / help).
  static String descriptionForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return 'Manage workspace settings and billing';
      case AppRole.manager:
        return 'Track projects and oversee team progress';
      case AppRole.member:
        return 'Complete tasks and collaborate with peers';
    }
  }
}
