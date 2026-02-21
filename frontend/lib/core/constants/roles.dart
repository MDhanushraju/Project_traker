/// App roles. Do not hardcode these in UI; use [AuthGuard] / [RoleAccess] for checks.
enum AppRole {
  admin,
  manager,
  teamLeader,
  member,
}

extension AppRoleExtension on AppRole {
  String get label {
    switch (this) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.manager:
        return 'Manager';
      case AppRole.teamLeader:
        return 'Team Leader';
      case AppRole.member:
        return 'Team Member';
    }
  }
}
