import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _kIdToken = 'id_token';
  static const _kIdTokenExp = 'id_token_exp'; // epoch seconds

  Future<void> saveIdToken(String token, int expiresAtEpochSec) async {
    await _storage.write(key: _kIdToken, value: token);
    await _storage.write(key: _kIdTokenExp, value: expiresAtEpochSec.toString());
  }

  Future<String?> getValidIdToken() async {
    final t = await _storage.read(key: _kIdToken);
    final expStr = await _storage.read(key: _kIdTokenExp);
    if (t == null || expStr == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = int.tryParse(expStr) ?? 0;
    if (now >= exp) return null; // expirado
    return t;
  }

  Future<void> clear() async {
    await _storage.delete(key: _kIdToken);
    await _storage.delete(key: _kIdTokenExp);
  }
}
