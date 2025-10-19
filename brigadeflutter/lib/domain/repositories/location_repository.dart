abstract class LocationRepository {
  Future<({double lat, double lng})?> current();
}
