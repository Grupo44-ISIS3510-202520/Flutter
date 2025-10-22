import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';
import '../../data/services_external/location/location_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final LocationService _location = LocationService();

  BrigadistProfile? _profile;
  bool _loading = false;
  bool _updating = false;

  ProfileViewModel(this._repository);

  BrigadistProfile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isUpdating => _updating;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(bool available) async {
    _updating = true;
    notifyListeners();

    try {
      await _repository.setAvailability(available);
      _profile = await _repository.getProfile();
    } finally {
      _updating = false;
      notifyListeners();
    }
  }

  Future<void> updateAvailabilityBasedOnLocation() async {
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
    final currentAvailability = _profile?.availableNow ?? false;

    if (insideCampus != currentAvailability) {
      await toggleAvailability(insideCampus);

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
}
