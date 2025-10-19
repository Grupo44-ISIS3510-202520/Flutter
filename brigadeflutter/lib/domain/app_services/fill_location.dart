import '../repositories/location_repository.dart';

class FillLocation {
  final LocationRepository repo;
  FillLocation(this.repo);
  Future<({double lat, double lng})?> call() => repo.current();
}
