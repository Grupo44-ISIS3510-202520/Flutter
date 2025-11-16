import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../../../core/workers/meeting_point_isolate.dart';
import '../../../data/models/meeting_point_model.dart';
import '../../../data/repositories/meeting_point_repository.dart';
import '../../../data/services_external/location/location_service.dart';

class LocationUnavailableException implements Exception {
  LocationUnavailableException([this.message = 'Location unavailable']);
  final String message;
}

class NearestMeetingResult {
  NearestMeetingResult({
    required this.point,
    required this.distanceMeters,
    this.usedIsolate = true
  });
  final MeetingPoint point;
  final double distanceMeters;
  final bool usedIsolate;
}

class FindNearestMeetingPoint {

  FindNearestMeetingPoint({
    required this.repository,
    required this.locationService,
    this.maxDistanceMeters = 500.0,
  });
  final MeetingPointRepository repository;
  final LocationService locationService;
  final double maxDistanceMeters;

  Future<NearestMeetingResult?> call() async {
    final Position? pos = await locationService.current();
    if (pos == null) {
      throw LocationUnavailableException();
    }

    final double userLat = pos.latitude;
    final double userLng = pos.longitude;

    final List<MeetingPoint> points = repository.getMeetingPoints();
    if (points.isEmpty) return null;

    final List<Map<String, Object>> pointsData = points.map((MeetingPoint p) => <String, Object>{
      'id': p.id,
      'name': p.name,
      'lat': p.lat,
      'lng': p.lng,
    }).toList();

    try {
      final Map<String, dynamic> isolateResult = await EmergencyIsolateWorker.findNearestMeetingPoint(
        userLat: userLat,
        userLng: userLng,
        meetingPoints: pointsData,
      );

      if (!isolateResult['success']) {
        final error = isolateResult['error'];
        final bool usedFallback = isolateResult['fallback'] == true;

        if (usedFallback) {
          throw Exception(error);
        }

        return _calculateInMainThread(userLat, userLng, points);
      }

      final Map<String, dynamic> resultData = isolateResult['result'] as Map<String, dynamic>;
      final bool usedFallback = isolateResult['fallback'] == true;

      final MeetingPoint nearestPoint = MeetingPoint(
        id: resultData['id'],
        name: resultData['name'],
        lat: resultData['lat'],
        lng: resultData['lng'],
      );

      final double distanceMeters = resultData['distanceMeters'] as double;

      return NearestMeetingResult(
          point: nearestPoint,
          distanceMeters: distanceMeters,
          usedIsolate: !usedFallback
      );
    } catch (e) {
      return _calculateInMainThread(userLat, userLng, points);
    }
  }

  NearestMeetingResult? _calculateInMainThread(
      double userLat,
      double userLng,
      List<MeetingPoint> points
      ) {
    try {
      MeetingPoint? nearest;
      double nearestDist = double.infinity;

      for (final MeetingPoint p in points) {
        final double d = _distanceMeters(userLat, userLng, p.lat, p.lng);
        if (d < nearestDist) {
          nearestDist = d;
          nearest = p;
        }
      }

      if (nearest == null) return null;

      return NearestMeetingResult(
          point: nearest,
          distanceMeters: nearestDist,
          usedIsolate: false
      );
    } catch (e) {
      rethrow;
    }
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const int R = 6371000;  
    final double phi1 = _toRad(lat1);
    final double phi2 = _toRad(lat2);
    final double dPhi = _toRad(lat2 - lat1);
    final double dLambda = _toRad(lon2 - lon1);

    final double a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180.0;
}