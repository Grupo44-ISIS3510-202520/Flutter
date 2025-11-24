import '../../helpers/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';

class SendPasswordResetEmail {
  SendPasswordResetEmail(this.repo);
  final AuthRepository repo;

  Future<void> call(String email) async {
    final String? err = validateEmailDomain(email);
    if (err != null) {
      throw ArgumentError(err); // valida dominio, longitud, emojis
    }
    await repo.sendPasswordResetEmail(email.trim());
  }
}
