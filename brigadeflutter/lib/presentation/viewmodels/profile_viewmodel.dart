import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/repositories/user_repository.dart';
import '../../data/services_external/location/location_service.dart';
import '../../data/entities/user_profile.dart';
import '../../data/entities/brigadist_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _repository;
  final LocationService _location = LocationService();
  final _firestore = FirebaseFirestore.instance;

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

    final prefs = await SharedPreferences.getInstance();
    final cachedProfile = prefs.getString('cached_profile');
    final lastUpdatedStr = prefs.getString('cached_profile_last_updated');

    // intentar cargar desde cache local
    if (cachedProfile != null && lastUpdatedStr != null) {
      final lastUpdated = DateTime.tryParse(lastUpdatedStr);
      final now = DateTime.now();
      if (lastUpdated != null &&
          now.difference(lastUpdated).inHours < 24) {
        final data = jsonDecode(cachedProfile);

        _profile = data['role'] == 'brigadist'
            ? BrigadistProfile(
                uid: data['uid'],
                name: data['name'],
                lastName: data['lastName'],
                uniandesCode: data['uniandesCode'],
                bloodGroup: data['bloodGroup'],
                role: data['role'],
                email: data['email'],
                availableNow: data['availableNow'] ?? false,
                timeSlots: List<String>.from(data['timeSlots'] ?? []),
                medals: List<String>.from(data['medals'] ?? []),
              )
            : UserProfile(
                uid: data['uid'],
                name: data['name'],
                lastName: data['lastName'],
                uniandesCode: data['uniandesCode'],
                bloodGroup: data['bloodGroup'],
                role: data['role'],
                email: data['email'],
                medals: List<String>.from(data['medals'] ?? []),
              );

        debugPrint('Loaded profile from cache ');
        _loading = false;
        notifyListeners();
      }
    }

    // cargar datos actualizados de firestore
    try {
      final user = await _repository.getProfile(uid);
      if (user == null) return;

      final trainingsSnap =
          await _firestore.collection('user_trainings').doc(uid).get();

      List<String> completedMedals = [];

      if (trainingsSnap.exists) {
        final data = trainingsSnap.data()!;
        data.forEach((key, value) {
          if (value is Map && (value['percent'] ?? 0) == 100) {
            completedMedals.add(key);
          }
        });
      }

      if (user.role.toLowerCase() == 'brigadist') {
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
          medals: completedMedals,
        );
      } else {
        _profile = UserProfile(
          uid: user.uid,
          name: user.name,
          lastName: user.lastName,
          uniandesCode: user.uniandesCode,
          bloodGroup: user.bloodGroup,
          role: user.role,
          email: user.email,
          medals: completedMedals,
        );
      }

      // Guardar en shared preferences
      await prefs.setString(
        'cached_profile',
        jsonEncode({
          'uid': _profile!.uid,
          'name': _profile!.name,
          'lastName': _profile!.lastName,
          'uniandesCode': _profile!.uniandesCode,
          'bloodGroup': _profile!.bloodGroup,
          'role': _profile!.role,
          'email': _profile!.email,
          'availableNow': (_profile is BrigadistProfile)
              ? (_profile as BrigadistProfile).availableNow
              : false,
          'timeSlots': (_profile is BrigadistProfile)
              ? (_profile as BrigadistProfile).timeSlots
              : [],
          'medals': _profile!.medals,
        }),
      );

      await prefs.setString(
          'cached_profile_last_updated', DateTime.now().toIso8601String());

      debugPrint('Profile cached locally 🔄');
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
      final brigadist =
          (_profile as BrigadistProfile).copyWith(availableNow: available);

      await _repository.saveProfile(brigadist);
      _profile = brigadist;

      // actualizar cache
      final prefs = await SharedPreferences.getInstance();
      final cachedProfile = prefs.getString('cached_profile');
      if (cachedProfile != null) {
        final data = jsonDecode(cachedProfile);
        data['availableNow'] = available;
        await prefs.setString('cached_profile', jsonEncode(data));
      }
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
