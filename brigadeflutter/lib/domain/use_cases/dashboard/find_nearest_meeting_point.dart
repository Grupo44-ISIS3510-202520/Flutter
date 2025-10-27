import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/meeting_point_model.dart';
import '../../../data/repositories/meeting_point_repository.dart';
import '../../../data/services_external/location/location_service.dart';

class LocationUnavailableException implements Exception {
  final String message;
  LocationUnavailableException([this.message = 'Location unavailable']);
}

class NearestMeetingResult {
  final MeetingPoint point;
  final double distanceMeters;
  NearestMeetingResult({required this.point, required this.distanceMeters});
}

class FindNearestMeetingPoint {
  final MeetingPointRepository repository;
  final LocationService locationService;
  final double maxDistanceMeters;

  FindNearestMeetingPoint({
    required this.repository,
    required this.locationService,
    this.maxDistanceMeters = 500.0,
  });

  Future<NearestMeetingResult?> call() async {
    final Position? pos = await locationService.current();
    if (pos == null) {
      throw LocationUnavailableException();
    }

    final userLat = pos.latitude;
    final userLng = pos.longitude;

    final points = repository.getMeetingPoints();
    if (points.isEmpty) return null;

    MeetingPoint? nearest;
    double nearestDist = double.infinity;

    for (final p in points) {
      final d = _distanceMeters(userLat, userLng, p.lat, p.lng);
      if (d < nearestDist) {
        nearestDist = d;
        nearest = p;
      }
    }

    if (nearest == null) return null;

    return NearestMeetingResult(point: nearest, distanceMeters: nearestDist);
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth radius in meters
    final phi1 = _toRad(lat1);
    final phi2 = _toRad(lat2);
    final dPhi = _toRad(lat2 - lat1);
    final dLambda = _toRad(lon2 - lon1);

    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180.0;
}
