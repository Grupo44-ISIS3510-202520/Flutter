import '../../data/entities/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

class ObserveAuthState {
  ObserveAuthState(this.repo);
  final AuthRepository repo;
  Stream<AuthUser?> call() => repo.observe();
}
