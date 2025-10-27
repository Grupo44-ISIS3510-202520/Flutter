import '../../data/entities/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repo;
  GetCurrentUser(this.repo);
  AuthUser? call() => repo.current();
}
