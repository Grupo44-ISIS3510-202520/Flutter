import '../../data/repositories/auth_repository.dart';
import '../../data/services_external/secure/token_service.dart';

class GetIdTokenCached {
  final AuthRepository authRepo;
  final TokenService tokenStore;
  GetIdTokenCached(this.authRepo, this.tokenStore);

  Future<String?> call() async {
    // intenta cache
    final cached = await tokenStore.getValidIdToken();
    if (cached != null) return cached;

    // pide a FirebaseAuth
    final fresh = await authRepo.getIdToken(forceRefresh: true);
    if (fresh == null) return null;

    // el id token expira ~3600s; guardamos now+3500s como margen
    final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3500;
    await tokenStore.saveIdToken(fresh, exp);
    return fresh;
  }
}
