import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) => _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) => _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> sendEmailVerification() async {
    final User? u = _auth.currentUser;
    if (u != null && !u.emailVerified) await u.sendEmailVerification();
  }

  Future<void> reloadUser() async => _auth.currentUser?.reload();

  Future<String?> getIdToken({bool forceRefresh = false}) async =>
      _auth.currentUser?.getIdToken(forceRefresh);

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email); // envía link de reseteo

  Future<void> signOut() => _auth.signOut();
}
