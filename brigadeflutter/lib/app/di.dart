import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/id_generator.dart';
import '../data/datasources/report_firestore_dao.dart';
import '../data/datasources/report_local_dao.dart';
import '../data/datasources/location_dao.dart';
import '../data/repositories_impl/report_repository_impl.dart';
import '../data/repositories_impl/location_repository_impl.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/location_repository.dart';
import '../data/services_external/firebase/firestore_service.dart';
import '../data/services_external/location/location_service.dart';
import '../domain/use_cases/create_emergency_report.dart';
import '../domain/use_cases/fill_location.dart';
import '../presentation/viewmodels/emergency_report_viewmodel.dart';

//protocol imports
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/protocols_firestore_dao.dart';
import '../data/repositories/protocol_repository.dart';
import '../data/repositories_impl/protocol_repository_impl.dart';
import '../domain/use_cases/protocols/get_protocols_stream.dart';
import '../domain/use_cases/protocols/mark_protocol_as_read.dart';
import '../domain/use_cases/protocols/is_protocol_new.dart';
import '../presentation/viewmodels/protocols_viewmodel.dart';


final sl = GetIt.instance;

Future<void> setupDi() async {
  final prefs = await SharedPreferences.getInstance();

  // external services
  sl.registerLazySingleton(() => FirestoreService());
  sl.registerLazySingleton(() => LocationService());

  // dao
  sl.registerLazySingleton(() => ReportFirestoreDao(sl()));
  sl.registerLazySingleton(() => ProtocolsFirestoreDao());
  sl.registerLazySingleton(() => ReportLocalDao()..init());
  sl.registerLazySingleton(() => LocationDao(sl()));


  // repos
  sl.registerLazySingleton<ReportRepository>(
          () => ReportRepositoryImpl(remote: sl(), local: sl()));
  sl.registerLazySingleton<LocationRepository>(
          () => LocationRepositoryImpl(sl()));
  sl.registerLazySingleton<ProtocolRepository>(
        () => ProtocolRepositoryImpl(dao: sl(), prefs: prefs),
  );

  // use cases
  sl.registerFactory(() => GetProtocolsStream(repository: sl()));
  sl.registerFactory(() => MarkProtocolAsRead(repository: sl()));
  sl.registerFactory(() => IsProtocolNew(repository: sl()));

  // app services
  sl.registerFactory(() => FillLocation(sl()));
  sl.registerLazySingleton(() => FirestoreIdGenerator());
  sl.registerFactory(() => CreateEmergencyReport(sl(), sl()));

  // viewmodels
  sl.registerFactory(() => EmergencyReportViewModel(
    createReport: sl(),
    fillLocation: sl(),
  ));
  sl.registerFactory(
        () => ProtocolsViewModel(
      getProtocolsStream: sl(),
      markProtocolAsRead: sl(),
      isProtocolNew: sl(),
    ),
  );
}