import '../entities/auth_user.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.uid,
    required this.email,
    this.displayName,
  });
  factory AuthUserModel.fromFirebaseUser(dynamic fbUser) => AuthUserModel(
    uid: fbUser.uid as String,
    email: (fbUser.email ?? '') as String,
    displayName: fbUser.displayName as String?,
  );
  final String uid;
  final String email;
  final String? displayName;

  AuthUser toEntity() =>
      AuthUser(uid: uid, email: email, displayName: displayName);
}
