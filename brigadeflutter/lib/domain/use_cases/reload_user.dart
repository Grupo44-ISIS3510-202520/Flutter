import '../../data/repositories/auth_repository.dart';

class ReloadUser {
  ReloadUser(this.repo);
  final AuthRepository repo;
  Future<void> call() => repo.reload();
}
