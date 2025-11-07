import '../entities/user_profile.dart';
import '../models/user_profile_model.dart';
import '../repositories/user_repository.dart';
import '../datasources/user_firestore_dao.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this.remote);
  final UserFirestoreDao remote;

  @override
  Future<void> saveProfile(UserProfile profile) =>
      remote.upsert(UserProfileModel.fromEntity(profile));

  @override
  Future<UserProfile?> getProfile(String uid) async =>
      (await remote.get(uid))?.toEntity();
}
