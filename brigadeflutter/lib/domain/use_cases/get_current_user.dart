import '../../data/entities/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

class GetCurrentUser {
  GetCurrentUser(this.repo);
  final AuthRepository repo;
  AuthUser? call() => repo.current();
}
