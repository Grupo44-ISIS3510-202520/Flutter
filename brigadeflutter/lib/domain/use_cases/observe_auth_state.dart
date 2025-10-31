import '../../data/entities/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

class ObserveAuthState {
  final AuthRepository repo;
  ObserveAuthState(this.repo);
  Stream<AuthUser?> call() => repo.observe();
}
