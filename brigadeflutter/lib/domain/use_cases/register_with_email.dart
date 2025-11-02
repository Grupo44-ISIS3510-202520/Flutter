import 'package:brigadeflutter/core/utils/validators.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/entities/user_profile.dart';

class RegisterWithEmail {
  final AuthRepository authRepo;
  final UserRepository userRepo;
  RegisterWithEmail(this.authRepo, this.userRepo);

  Future<void> call({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String lastName,
    required String uniandesCode,
    required String bloodGroup,
    required String role,
  })async {
    final problems = <String?>[
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
      throw ArgumentError(problems.first);
    }

    final user = await authRepo.registerWithEmail(email: email.trim(), password: password);

    final profile = UserProfile(
      uid: user.uid,
      email: email.trim(),
      name: name.trim(),
      lastName: lastName.trim(),
      uniandesCode: uniandesCode.trim(),
      bloodGroup: bloodGroup,
      role: role,
    );

    await userRepo.saveProfile(profile);
  }
}