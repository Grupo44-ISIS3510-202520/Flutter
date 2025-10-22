import 'package:brigadeflutter/data/repositories_impl/profile_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/id_generator.dart';
import '../data/services_external/firebase/firestore_service.dart';
import '../data/datasources/report_firestore_dao.dart';
import '../data/datasources/report_local_dao.dart';
import '../data/repositories_impl/report_repository_impl.dart';
import '../data/repositories/report_repository.dart';
import '../domain/use_cases/create_emergency_report.dart';
import '../data/services_external/firebase/firestore_service.dart';
import '../data/services_external/location/location_service.dart';
import '../data/datasources/report_local_dao.dart';
import '../data/datasources/location_dao.dart';
import '../data/repositories_impl/report_repository_impl.dart';
import '../data/repositories_impl/location_repository_impl.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/location_repository.dart';
import '../domain/use_cases/fill_location.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  // external services
  sl.registerLazySingleton(() => FirestoreService());
  sl.registerLazySingleton(() => LocationService());

  // dao
  sl.registerLazySingleton(() => ReportFirestoreDao(sl()));
  sl.registerLazySingleton(() => ReportLocalDao()..init());
  sl.registerLazySingleton(() => LocationDao(sl()));

  // repos
  sl.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(remote: sl(), local: sl()));
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => InMemoryProfileRepository());


  // app services
  sl.registerFactory(() => FillLocation(sl()));
  sl.registerLazySingleton(() => FirestoreIdGenerator());
  sl.registerFactory(() => CreateEmergencyReport(sl(), sl()));
}