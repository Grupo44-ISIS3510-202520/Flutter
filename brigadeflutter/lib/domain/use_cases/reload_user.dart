import '../../data/repositories/auth_repository.dart';

class ReloadUser {
  final AuthRepository repo;
  ReloadUser(this.repo);
  Future<void> call() => repo.reload();
}
