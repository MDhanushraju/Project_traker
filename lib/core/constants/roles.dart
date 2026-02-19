/// App roles. Do not hardcode these in UI; use [AuthGuard] / [RoleAccess] for checks.
enum AppRole {
  admin,
  manager,
  member,
}

extension AppRoleExtension on AppRole {
  String get label {
    switch (this) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.manager:
        return 'Manager';
      case AppRole.member:
        return 'Team Member';
    }
  }
}
