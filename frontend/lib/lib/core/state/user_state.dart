/// User state value. Use with [AuthState] for full auth; this is for extra user profile data if needed.
class UserState {
  const UserState({this.displayName, this.email});
  final String? displayName;
  final String? email;
}
