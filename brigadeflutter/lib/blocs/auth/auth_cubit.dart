
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthCubit(): super(const AuthState()){
    _auth.authStateChanges().listen((u){
      emit(state.copyWith(uid: u?.uid, email: u?.email, loading: false, error: null));
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.sendEmailVerification(); // buenas prácticas
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      await _auth.sendPasswordResetEmail(email: email);
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> signOut() async => _auth.signOut();

}
