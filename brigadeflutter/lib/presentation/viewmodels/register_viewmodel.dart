import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/validators.dart';
import '../../domain/use_cases/register_with_email.dart';
import '../../domain/use_cases/reload_user.dart';
import '../../domain/use_cases/send_email_verification.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({
    required this.registerUC,
    required this.sendVerifyUC,
    required this.reloadUserUC,
  }) {
    _connSub = Connectivity().onConnectivityChanged.listen((_) async {
      final List<ConnectivityResult> res = await Connectivity().checkConnectivity();
      isOnline = !res.contains(ConnectivityResult.none);
      notifyListeners(); // update state
    });
  }
  // Use cases
  final RegisterWithEmail registerUC;
  final SendEmailVerification sendVerifyUC;
  final ReloadUser reloadUserUC;

  // state
  bool submitting = false;
  bool isOnline = true;
  String? error;
  bool verificationSent = false;

  // Subscriptions
  StreamSubscription? _connSub;

  Future<bool> submit({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String lastName,
    required String uniandesCode,
    required String bloodGroup,
    required String role,
  }) async {
    if (!isOnline) {
      error =
          'Hey Uniandino, you’re offline! Reconnect to get all features back.';
      notifyListeners();
      return false;
    }

    // validación en VM
    final List<String> problems = <String?>[
      validateEmailDomain(email),
      validatePassword(password),
      validatePasswordConfirm(confirmPassword, password),
      validateName(name),
      validateLastName(lastName),
      validateUniandesCode(uniandesCode),
      validateBloodGroup(bloodGroup),
      validateRole(role),
    ].whereType<String>().toList();
    if (problems.isNotEmpty) {
      error = problems.first;
      notifyListeners();
      return false;
    }

    submitting = true;
    error = null;
    notifyListeners(); // update state
    try {
      await registerUC(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        name: name,
        lastName: lastName,
        uniandesCode: uniandesCode,
        bloodGroup: bloodGroup,
        role: role,
      );
      await sendVerifyUC();
      verificationSent = true;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // mensaje personalizado si el email ya existe
      if (e.code == 'email-already-in-use') {
        error =
            'Sorry $name, you already have an account. Try resetting your password.';
      } else {
        error = e.message ?? e.code;
      }
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      submitting = false;
      notifyListeners(); // update state
    }
  }

  Future<void> reloadUser() => reloadUserUC();

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }
}
