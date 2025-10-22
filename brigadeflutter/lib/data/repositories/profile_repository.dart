import '../models/profile_model.dart';

abstract class ProfileRepository {
  Future<BrigadistProfile> getProfile();
  Future<void> setAvailability(bool available);
}
