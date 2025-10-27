import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> observe();
  AuthUser? current();

  Future<AuthUser> signInWithEmail({required String email, required String password});
  Future<AuthUser> registerWithEmail({required String email, required String password});

  Future<void> sendEmailVerification();
  Future<void> reload();

  Future<String?> getIdToken({bool forceRefresh = false});

  Future<void> sendPasswordResetEmail(String email);
  
  Future<void> signOut();
}
