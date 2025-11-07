import '../../data/repositories/auth_repository.dart';

class SignOut {
  SignOut(this.repo);
  final AuthRepository repo;
  Future<void> call() => repo.signOut();
}
