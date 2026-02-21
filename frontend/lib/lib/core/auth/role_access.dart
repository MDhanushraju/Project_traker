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
    AppRoutes.users,
    AppRoutes.settings,
  };

  /// Public route; no role required.
  static const String publicRoute = AppRoutes.login;

  /// Default route after login for each role.
  static String defaultRouteForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
      case AppRole.manager:
      case AppRole.teamLeader:
      case AppRole.member:
        return AppRoutes.dashboard;
    }
  }

  /// Routes the given role is allowed to access (for nav links, no hardcoded role checks in UI).
  /// Team Leader: dashboard only (their hub with projects, team, tasks). No Projects/Users/Settings.
  static List<String> allowedRoutesForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return [AppRoutes.dashboard, AppRoutes.projects, AppRoutes.tasks, AppRoutes.users, AppRoutes.settings];
      case AppRole.manager:
        return [AppRoutes.dashboard, AppRoutes.projects, AppRoutes.tasks, AppRoutes.users];
      case AppRole.teamLeader:
        return [AppRoutes.dashboard];
      case AppRole.member:
        return [AppRoutes.dashboard, AppRoutes.tasks];
    }
  }

  /// Sub-routes reachable from dashboard but not in main nav.
  /// Admin and Manager both get: assignProject, assignTask, shiftTeamMember, etc.
  static const Set<String> adminManagerSubRoutes = {
    AppRoutes.assignProject,
    AppRoutes.assignTask,
    AppRoutes.shiftTeamMember,
    AppRoutes.teamOverview,
    AppRoutes.userDetails,
    AppRoutes.clients,
    AppRoutes.projectSettings,
    AppRoutes.addNewProject,
    AppRoutes.addSmallChange,
    AppRoutes.updateExistingProject,
  };

  /// Profile/sub-routes any logged-in user can access.
  static const Set<String> profileSubRoutes = {AppRoutes.personalDetails};

  /// Sub-routes for Team Leader: user details, assign task.
  static const Set<String> teamLeaderSubRoutes = {
    AppRoutes.userDetails,
    AppRoutes.assignTask,
    AppRoutes.teamOverview,
  };

  /// Sub-routes for Team Member: team overview (view project).
  static const Set<String> memberSubRoutes = {
    AppRoutes.teamOverview,
  };

  /// Whether [role] can access [routeName]. Used by [AuthGuard] only.
  static bool canAccessRoute(AppRole? role, String routeName) {
    if (role == null) return false;
    if (profileSubRoutes.contains(routeName)) return true;
    if (adminManagerSubRoutes.contains(routeName) &&
        (role == AppRole.admin || role == AppRole.manager)) {
      return true;
    }
    if (teamLeaderSubRoutes.contains(routeName) && role == AppRole.teamLeader) {
      return true;
    }
    if (memberSubRoutes.contains(routeName) && role == AppRole.member) {
      return true;
    }
    return allowedRoutesForRole(role).contains(routeName);
  }

  /// Human-readable description of what each role can access (for login / help).
  static String descriptionForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return 'Manage workspace settings and billing';
      case AppRole.manager:
        return 'Track projects and oversee team progress';
      case AppRole.teamLeader:
        return 'View assigned projects, team members, assign tasks';
      case AppRole.member:
        return 'View projects, tasks, message team leader & members';
    }
  }
}
