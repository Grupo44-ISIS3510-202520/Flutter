import '../repositories/location_repository.dart';
import '../datasources/location_dao.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDao dao;
  LocationRepositoryImpl(this.dao);
  @override
  Future<({double lat, double lng})?> current() => dao.current();
}
