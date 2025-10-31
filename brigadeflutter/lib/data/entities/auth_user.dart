class AuthUser {
  final String uid;
  final String email;
  final String? displayName;
  const AuthUser({required this.uid, required this.email, this.displayName});
}
