import '../services_external/firebase/firestore_service.dart';
import '../models/user_profile_model.dart';

class UserFirestoreDao {
  final FirestoreService _fs;
  UserFirestoreDao(this._fs);

  Future<void> upsert(UserProfileModel m) async {
    await _fs.setDoc('users', m.uid, m.toJson()); // upsert
  }

  Future<UserProfileModel?> get(String uid) async {
    final data = await _fs.getDoc('users', uid);
    if (data == null) return null;
    return UserProfileModel.fromJson(uid, data);
  }
}