import '../../data/repositories/auth_repository.dart';

class SendEmailVerification {
  final AuthRepository repo;
  SendEmailVerification(this.repo);
  Future<void> call() => repo.sendEmailVerification();
}
