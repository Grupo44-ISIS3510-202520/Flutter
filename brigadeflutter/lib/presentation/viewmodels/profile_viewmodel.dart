import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/entities/brigadist_profile.dart';
import '../../data/entities/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services_external/location/location_service.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._repository);
  final UserRepository _repository;
  final LocationService _location = LocationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProfile? _profile;
  bool _loading = false;
  bool _updating = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isUpdating => _updating;

  Future<void> load(String uid) async {
    _loading = true;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedProfile = prefs.getString('cached_profile');
    final String? lastUpdatedStr = prefs.getString('cached_profile_last_updated');

    // intentar cargar desde cache local
    if (cachedProfile != null && lastUpdatedStr != null) {
      final DateTime? lastUpdated = DateTime.tryParse(lastUpdatedStr);
      final DateTime now = DateTime.now();
      if (lastUpdated != null && now.difference(lastUpdated).inHours < 24) {
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
                timeSlots: List<String>.from(data['timeSlots'] ?? <dynamic>[]),
                medals: List<String>.from(data['medals'] ?? <dynamic>[]),
              )
            : UserProfile(
                uid: data['uid'],
                name: data['name'],
                lastName: data['lastName'],
                uniandesCode: data['uniandesCode'],
                bloodGroup: data['bloodGroup'],
                role: data['role'],
                email: data['email'],
                medals: List<String>.from(data['medals'] ?? <dynamic>[]),
              );

        debugPrint('Loaded profile from cache ');
        _loading = false;
        notifyListeners();
      }
    }

    // cargar datos actualizados de firestore
    try {
      final UserProfile? user = await _repository.getProfile(uid);
      if (user == null) return;

      final DocumentSnapshot<Map<String, dynamic>> trainingsSnap = await _firestore
          .collection('user_trainings')
          .doc(uid)
          .get();

      final List<String> completedMedals = <String>[];

      if (trainingsSnap.exists) {
        final Map<String, dynamic> data = trainingsSnap.data()!;
        data.forEach((String key, value) {
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
          timeSlots: const <String>['08:00–12:00', '14:00–18:00'],
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
        jsonEncode(<String, Object>{
          'uid': _profile!.uid,
          'name': _profile!.name,
          'lastName': _profile!.lastName,
          'uniandesCode': _profile!.uniandesCode,
          'bloodGroup': _profile!.bloodGroup,
          'role': _profile!.role,
          'email': _profile!.email,
          'availableNow': (_profile is BrigadistProfile)
              ? (_profile! as BrigadistProfile).availableNow
              : false,
          'timeSlots': (_profile is BrigadistProfile)
              ? (_profile! as BrigadistProfile).timeSlots
              : <dynamic>[],
          'medals': _profile!.medals,
        }),
      );

      await prefs.setString(
          'cached_profile_last_updated', DateTime.now().toIso8601String());

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
      final BrigadistProfile brigadist = (_profile! as BrigadistProfile).copyWith(
        availableNow: available,
      );

      await _repository.saveProfile(brigadist);
      _profile = brigadist;

      // actualizar cache
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedProfile = prefs.getString('cached_profile');
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

    final Position? pos = await _location.current();
    if (pos == null) return;

    const double uniandesLat = 4.601297;
    const double uniandesLon = -74.066140;
    const int campusRadius = 250;

    final double distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      uniandesLat,
      uniandesLon,
    );

    final bool insideCampus = distance <= campusRadius;

    await FirebaseAnalytics.instance.logEvent(
      name: insideCampus ? 'auto_available_on' : 'auto_available_off',
      parameters: <String, Object>{
        'distance_meters': distance,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      },
    );
  }
}
