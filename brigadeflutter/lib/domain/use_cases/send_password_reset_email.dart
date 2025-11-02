import '../../data/repositories/auth_repository.dart';
import '../../core/utils/validators.dart';

class SendPasswordResetEmail {
  SendPasswordResetEmail(this.repo);
  final AuthRepository repo;

  Future<void> call(String email) async {
    final err = validateEmailDomain(email);
    if (err != null) {
      throw ArgumentError(err); // valida dominio, longitud, emojis
    }
    await repo.sendPasswordResetEmail(email.trim());
  }
}
