import 'package:firebase_auth/firebase_auth.dart';

import '../entities/auth_user.dart';
import '../models/auth_user_model.dart';
import '../repositories/auth_repository.dart';
import '../services_external/firebase/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth);
  final AuthService _auth;

  @override
  Stream<AuthUser?> observe() => _auth.authStateChanges().map(
    (User? u) => u == null ? null : AuthUserModel.fromFirebaseUser(u).toEntity(),
  );

  @override
  AuthUser? current() {
    final User? u = _auth.currentUser;
    return u == null ? null : AuthUserModel.fromFirebaseUser(u).toEntity();
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.signInWithEmail(email: email, password: password);
    return AuthUserModel.fromFirebaseUser(cred.user).toEntity();
  }

  @override
  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.registerWithEmail(
      email: email,
      password: password,
    );
    return AuthUserModel.fromFirebaseUser(cred.user).toEntity();
  }

  @override
  Future<void> sendEmailVerification() => _auth.sendEmailVerification();

  @override
  Future<void> reload() => _auth.reloadUser();

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _auth.getIdToken(forceRefresh: forceRefresh);

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email);
}
