import 'package:geolocator_platform_interface/src/models/position.dart';

import '../services_external/location/location_service.dart';

// dao de ubicación delega al service
class LocationDao {
  LocationDao(this._svc);
  final LocationService _svc;

  Future<({double lat, double lng})?> current() async {
    final Position? pos = await _svc.current();
    if (pos == null) return null;
    return (lat: pos.latitude, lng: pos.longitude);
  }
}
