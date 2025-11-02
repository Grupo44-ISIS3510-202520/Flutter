import '../repositories/location_repository.dart';
import '../datasources/location_dao.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(this.dao);
  final LocationDao dao;
  @override
  Future<({double lat, double lng})?> current() => dao.current();
}
