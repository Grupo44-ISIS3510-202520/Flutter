import '../../data/repositories/auth_repository.dart';

class SendEmailVerification {
  SendEmailVerification(this.repo);
  final AuthRepository repo;
  Future<void> call() => repo.sendEmailVerification();
}
