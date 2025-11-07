import '../entities/auth_user.dart';

class AuthUserModel {
  factory AuthUserModel.fromFirebaseUser(dynamic fbUser) => AuthUserModel(
    uid: fbUser.uid as String,
    email: (fbUser.email ?? '') as String,
    displayName: fbUser.displayName as String?,
  );
  const AuthUserModel({
    required this.uid,
    required this.email,
    this.displayName,
  });
  final String uid;
  final String email;
  final String? displayName;

  AuthUser toEntity() =>
      AuthUser(uid: uid, email: email, displayName: displayName);
}
