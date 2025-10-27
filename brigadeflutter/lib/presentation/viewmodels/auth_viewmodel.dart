import 'dart:async';

import 'package:brigadeflutter/core/utils/validators.dart';
import 'package:brigadeflutter/domain/use_cases/send_password_reset_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/use_cases/sign_in_with_email.dart';
import '../../domain/use_cases/sign_out.dart';
import '../../domain/use_cases/observe_auth_state.dart';
import '../../domain/use_cases/get_current_user.dart';
import '../../data/entities/auth_user.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInWithEmail signIn;
  final SignOut signOutUC;
  final ObserveAuthState observe;
  final GetCurrentUser getCurrent;
  final SendPasswordResetEmail sendReset;
  bool isOnline = true;
  StreamSubscription? _connSub;

  AuthViewModel({
    required this.signIn,
    required this.signOutUC,
    required this.observe,
    required this.getCurrent,
    required this.sendReset,
  }) {
    _sub = observe().listen((u) {
      user = u;
      isAuthenticated = u != null;
      notifyListeners();
    });
    user = getCurrent();
    isAuthenticated = user != null;

    // monitor de conectividad
    _connSub = Connectivity().onConnectivityChanged.listen((_) async {
      final res = await Connectivity().checkConnectivity();
      isOnline = !res.contains(ConnectivityResult.none);
      notifyListeners(); // update state
    });
  }

  AuthUser? user;
  bool isAuthenticated = false;
  bool signingIn = false;
  bool resetting = false;
  String? error;

  Future<bool> forgotPassword(String email) async {
    if (resetting) return false;
    error = null;

    if (!isOnline) {
      error =
          "Hey Uniandino, you’re offline! Reconnect to get all features back.";
      notifyListeners();
      return false;
    }

    final err = validateEmailDomain(email);
    if (err != null) {
      error = err;
      notifyListeners();
      return false;
    }

    resetting = true;
    notifyListeners(); // update state
    try {
      await sendReset(email);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      resetting = false;
      notifyListeners(); // update state
    }
  }

  StreamSubscription<AuthUser?>? _sub;

  Future<void> login(String email, String password) async {
    if (signingIn) return;
    error = null;

    if (!isOnline) {
      error =
          "Hey Uniandino, you’re offline! Reconnect to get all features back.";
      notifyListeners();
      return;
    }

    final problems = <String?>[
      validateEmailDomain(email),
      validatePassword(password),
    ].whereType<String>().toList();
    if (problems.isNotEmpty) {
      error = problems.first;
      notifyListeners();
      return;
    }

    signingIn = true;
    notifyListeners(); // update state

    try {
      await signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Manejamos errores específicos
      switch (e.code) {
        case 'user-not-found':
          error = "Oops! Account not found. Check your email or sign up.";
          break;
        case 'wrong-password':
          error = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          error = "Invalid email format. Please check and try again.";
          break;
        case 'too-many-requests':
          error = "Too many attempts. Please wait a few minutes.";
          break;
        default:
          error = e.message ?? "Login failed. Please try again.";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      signingIn = false;
      notifyListeners();
    }
  }

  Future<void> logout() => signOutUC();

  @override
  void dispose() {
    _sub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }
}
