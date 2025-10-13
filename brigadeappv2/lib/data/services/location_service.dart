import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double campusLat = 4.6014;
  static const double campusLng = -74.0661;
  static const double radiusMeters = 150.0;

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onCampusChange => _controller.stream;

  bool _wasInside = false;

  Future<Position?> current() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> startCampusMonitor() async {
    await Geolocator.requestPermission();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 20,
      ),
    ).listen((pos) {
      final distance = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, campusLat, campusLng,
      );

      final inside = distance <= radiusMeters;
      if (inside != _wasInside) {
        _wasInside = inside;
        _controller.add(inside);
      }
    });
  }

  void dispose() => _controller.close();
}
