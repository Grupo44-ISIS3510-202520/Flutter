import '../../data/repositories/location_repository.dart';

class FillLocation {
  FillLocation(this.repo);
  final LocationRepository repo;
  Future<({double lat, double lng})?> call() => repo.current();
}
