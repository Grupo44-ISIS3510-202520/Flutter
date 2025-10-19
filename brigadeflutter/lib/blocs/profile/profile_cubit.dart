// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:brigadeflutter/blocs/profile/profile_state.dart';
// import 'package:brigadeflutter/blocs/profile/profile_repository.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:brigadeflutter/services/location_service.dart';
// import 'package:geolocator/geolocator.dart';

// class ProfileCubit extends Cubit<ProfileState> {
//   final ProfileRepository repo;
//   final LocationService _location = LocationService();
//   ProfileCubit(this.repo) : super(const ProfileState());

//   Future<void> load() async {
//     emit(state.copyWith(loading: true));
//     final p = await repo.getProfile();
//     emit(state.copyWith(profile: p, loading: false));
//   }

//   Future<void> toggleAvailability(bool v) async {
//     emit(state.copyWith(updating: true));
//     await repo.setAvailability(v);
//     final p = await repo.getProfile();
//     emit(state.copyWith(profile: p, updating: false));
//   }

//   Future<void> updateAvailabilityBasedOnLocation() async {
//     final pos = await _location.current();
//     if (pos == null) return;

//     const uniandesLat = 4.601297;
//     const uniandesLon = -74.066140;
//     const campusRadius = 250;

//     final distance = Geolocator.distanceBetween(
//       pos.latitude,
//       pos.longitude,
//       uniandesLat,
//       uniandesLon,
//     );

//     final insideCampus = distance <= campusRadius;
//     final currentAvailability = state.profile?.availableNow ?? false;

//     if (insideCampus != currentAvailability) {
//       await toggleAvailability(insideCampus);

//       await FirebaseAnalytics.instance.logEvent(
//         name: insideCampus ? 'auto_available_on' : 'auto_available_off',
//         parameters: {
//           'distance_meters': distance,
//           'latitude': pos.latitude,
//           'longitude': pos.longitude,
//         },
//       );
//     }
//   }
// }
