import '../../data/repositories/auth_repository.dart';

class SignInWithEmail {
  SignInWithEmail(this.repo);
  final AuthRepository repo;

  Future<void> call({required String email, required String password}) async {
    // validaciones básicas
    final e = email.trim();
    final p = password;
    if (e.isEmpty || !e.contains('@')) throw ArgumentError('email inválido');
    if (p.length < 6) throw ArgumentError('password inválido');
    await repo.signInWithEmail(email: e, password: p);
  }
}
