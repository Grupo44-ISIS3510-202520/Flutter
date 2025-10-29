import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services_external/location/location_service.dart';
import '../../data/entities/user_profile.dart';
import '../../data/entities/brigadist_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _repository;
  final LocationService _location = LocationService();

  UserProfile? _profile;
  bool _loading = false;
  bool _updating = false;

  ProfileViewModel(this._repository);

  UserProfile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isUpdating => _updating;

  Future<void> load(String uid) async {
    _loading = true;
    notifyListeners();

    try {
      final user = await _repository.getProfile(uid);

      if (user != null && user.role.toLowerCase() == 'brigadist') {
        _profile = BrigadistProfile(
          uid: user.uid,
          name: user.name,
          lastName: user.lastName,
          uniandesCode: user.uniandesCode,
          bloodGroup: user.bloodGroup,
          role: user.role,
          email: user.email,
          availableNow: false,
          timeSlots: const ['08:00–12:00', '14:00–18:00'],
          medals: const ["First Aid", "Fire Drill", "Leadership", "Evacuation"],
        );
      } else {
        _profile = user;
      }
    } catch (e, st) {
      debugPrint('Error loading profile: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(bool available) async {
    if (_profile == null) return;
    if (_profile is! BrigadistProfile) return;

    _updating = true;
    notifyListeners();

    try {
      final brigadist = (_profile as BrigadistProfile)
          .copyWith(availableNow: available);

      await _repository.saveProfile(brigadist);
      _profile = brigadist;
    } catch (e, st) {
      debugPrint('Error toggling availability: $e\n$st');
    } finally {
      _updating = false;
      notifyListeners();
    }
  }

  Future<void> updateAvailabilityBasedOnLocation() async {
    if (_profile == null || _profile is! BrigadistProfile) return;

    final pos = await _location.current();
    if (pos == null) return;

    const uniandesLat = 4.601297;
    const uniandesLon = -74.066140;
    const campusRadius = 250;

    final distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      uniandesLat,
      uniandesLon,
    );

    final insideCampus = distance <= campusRadius;

    await FirebaseAnalytics.instance.logEvent(
      name: insideCampus ? 'auto_available_on' : 'auto_available_off',
      parameters: {
        'distance_meters': distance,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      },
    );
  }
}