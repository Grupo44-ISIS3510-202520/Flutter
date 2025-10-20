import 'package:brigadeflutter/data/services_external/location/location_service.dart';

// dao de ubicación delega al service
class LocationDao {
  final LocationService _svc;
  LocationDao(this._svc);

  Future<({double lat, double lng})?> current() async {
    final pos = await _svc.current();
    if (pos == null) return null;
    return (lat: pos.latitude, lng: pos.longitude);
  }
}
