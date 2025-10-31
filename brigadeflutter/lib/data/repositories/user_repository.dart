import '../entities/user_profile.dart';

abstract class UserRepository {
  Future<void> saveProfile(UserProfile profile);
  Future<UserProfile?> getProfile(String uid);
}
