import 'package:flutter/foundation.dart';

import '../constants/roles.dart';
import 'role_access.dart';

/// Immutable value for the currently logged-in user.
class AuthUser {
  const AuthUser({required this.role, this.displayName});

  final AppRole role;
  final String? displayName;

  String get label => role.label;
  String get defaultRoute => RoleAccess.defaultRouteForRole(role);
}

/// App-wide auth state. Listen to this to rebuild when login/logout changes.
/// Do not hardcode role checks in UI; use [RoleAccess] / [AuthGuard] for access.
final class AuthState extends ChangeNotifier {
  AuthState._();

  static final AuthState instance = AuthState._();

  AuthUser? _user;

  AuthUser? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  AppRole? get role => _user?.role;

  /// Log in as the given role. Use for manual toggle / checkpoint testing.
  void login(AppRole role, {String? displayName}) {
    _user = AuthUser(role: role, displayName: displayName ?? role.label);
    notifyListeners();
  }

  /// Log out. Guard will redirect to /login.
  void logout() {
    _user = null;
    notifyListeners();
  }
}
