import 'profile_models.dart';

abstract class ProfileRepository {
  Future<BrigadistProfile> getProfile();
  Future<void> setAvailability(bool available);
}

// Mock en memoria
class InMemoryProfileRepository implements ProfileRepository {
  BrigadistProfile _p = const BrigadistProfile(
    name: 'Mario',
    bloodType: 'O',
    rh: '+',
    availableNow: true,
    timeSlots: ['08:00–12:00', '14:00–18:00'],
    medals: ['Medal 1', 'Medal 2', 'Medal 3', 'Medal 4'],
  );

  @override
  Future<BrigadistProfile> getProfile() async => _p;

  @override
  Future<void> setAvailability(bool available) async {
    _p = _p.copyWith(availableNow: available);
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
}