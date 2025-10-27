import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// external services
import 'package:brigadeflutter/data/services_external/ambient_light_service.dart';
import 'package:brigadeflutter/data/services_external/screen_brightness_service.dart';
import 'package:brigadeflutter/data/services_external/firebase/auth_service.dart';
import 'package:brigadeflutter/data/services_external/firebase/firestore_service.dart';
import 'package:brigadeflutter/data/services_external/location/location_service.dart';
import 'package:brigadeflutter/data/services_external/secure/token_service.dart';

// core
import '../core/utils/id_generator.dart';

// data - datasources
import '../data/datasources/location_dao.dart';
import '../data/datasources/report_firestore_dao.dart';
import '../data/datasources/report_local_dao.dart';
import '../data/datasources/protocols_firestore_dao.dart';
import '../data/datasources/user_firestore_dao.dart';

// data - repositories & implementations
import '../data/repositories/location_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/protocol_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories_impl/location_repository_impl.dart';
import '../data/repositories_impl/meeting_point_repository_impl.dart';
import '../data/repositories_impl/report_repository_impl.dart';
import '../data/repositories_impl/protocol_repository_impl.dart';
import '../data/repositories_impl/user_repository_impl.dart';
import '../data/repositories_impl/auth_repository_impl.dart';

// domain - use cases
// import '../domain/use_cases/adjust_screen_light.dart';
import '../domain/use_cases/adjust_brightness_from_ambient.dart';
import '../domain/use_cases/create_emergency_report.dart';
import '../domain/use_cases/fill_location.dart';
import '../domain/use_cases/send_password_reset_email.dart';
import '../domain/use_cases/protocols/get_protocols_stream.dart';
import '../domain/use_cases/protocols/mark_protocol_as_read.dart';
import '../domain/use_cases/protocols/is_protocol_new.dart';
import '../domain/use_cases/register_with_email.dart';
import '../domain/use_cases/send_email_verification.dart';
import '../domain/use_cases/reload_user.dart';
import '../domain/use_cases/get_id_token_cache.dart';
import '../domain/use_cases/sign_in_with_email.dart';
import '../domain/use_cases/observe_auth_state.dart';
import '../domain/use_cases/get_current_user.dart';
import '../domain/use_cases/sign_out.dart';

//dashboard
import '../domain/use_cases/dashboard/find_nearest_meeting_point.dart';
import '../data/repositories/meeting_point_repository.dart';

// presentation - viewmodels & navigation
import '../presentation/viewmodels/cas_brightness_viewmodel.dart';
import '../presentation/viewmodels/emergency_report_viewmodel.dart';
import '../presentation/viewmodels/protocols_viewmodel.dart';
import '../presentation/viewmodels/register_viewmodel.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/dashboard_viewmodel.dart';
import '../presentation/navigation/dashboard_actions_factory.dart';

import '../data/services_external/openai_service.dart';
import '../data/services_external/tts_service.dart';
import '../data/services_external/connectivity_service.dart';
import '../presentation/viewmodels/emergency_report_viewmodel.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDi() async {
  final prefs = await SharedPreferences.getInstance();
  //print('GetIt hash in setupDi: ${GetIt.instance.hashCode}');


  // external services
  sl.registerLazySingleton(() => FirestoreService());
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton(() => AuthService(auth: FirebaseAuth.instance));
  sl.registerLazySingleton<AmbientLightService>(
    () => AmbientLightServiceImpl(),
  );
  sl.registerLazySingleton<ScreenBrightnessService>(
    () => ScreenBrightnessServiceImpl(),
  );
  sl.registerLazySingleton(() => TokenService());
  sl.registerLazySingleton<OpenAIService>(() => OpenAIService());
  sl.registerLazySingleton<TtsService>(() => TtsService());
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(),
  );

  // DAOs
  sl.registerLazySingleton(() => ReportFirestoreDao(sl()));
  sl.registerLazySingleton(() => ProtocolsFirestoreDao());
  sl.registerLazySingleton(() => ReportLocalDao()..init());
  sl.registerLazySingleton(() => LocationDao(sl()));
  sl.registerLazySingleton(() => UserFirestoreDao(sl()));

  // Repositories
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProtocolRepository>(
    () => ProtocolRepositoryImpl(dao: sl(), prefs: prefs),
  );
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<MeetingPointRepository>(
        () => MeetingPointRepositoryImpl(),
  );

  // App services / helpers
  // App services / helpers
  sl.registerLazySingleton(() => FirestoreIdGenerator());

  //Use cases - dashboard
  sl.registerLazySingleton(() => FindNearestMeetingPoint(
    locationService: sl(),
    repository: sl(),
  ));

  // Use cases - protocols
  sl.registerFactory(() => GetProtocolsStream(repository: sl()));
  sl.registerFactory(() => MarkProtocolAsRead(repository: sl()));
  sl.registerFactory(() => IsProtocolNew(repository: sl()));

  // Use cases - reports & location
  sl.registerFactory(() => FillLocation(sl()));
  sl.registerFactory(() => CreateEmergencyReport(sl(), sl()));

  // Use cases - auth
  sl.registerFactory(() => RegisterWithEmail(sl(), sl()));
  sl.registerFactory(() => SendEmailVerification(sl()));
  sl.registerFactory(() => ReloadUser(sl()));
  sl.registerFactory(() => GetIdTokenCached(sl(), sl()));
  sl.registerFactory(() => SignInWithEmail(sl()));
  sl.registerFactory(() => ObserveAuthState(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
  sl.registerFactory(() => SignOut(sl()));
  sl.registerFactory(() => SendPasswordResetEmail(sl()));

  // // Use case - brightness
  // sl.registerFactory(
  //   () => AdjustBrightnessFromAmbient(
  //     sl<AmbientLightService>(),
  //     sl<ScreenBrightnessService>(),
  //   ),
  // );

try {
  sl.registerLazySingleton<AdjustBrightnessFromAmbient>(
    () => AdjustBrightnessFromAmbient(
      sl<AmbientLightService>(),
      sl<ScreenBrightnessService>(),
    ),
  );
  print('// YYYYEYEYYEYEYE/////////// AdjustBrightnessFromAmbient registered');
} catch (e, s) {
  print('/////////////////// Error registering AdjustBrightnessFromAmbient: $e');
  print(s);
}

  assert(
    sl.isRegistered<AdjustBrightnessFromAmbient>(),
    'AdjustBrightnessFromAmbient not registered in GetIt',
  );

  // ViewModels
  sl.registerFactory(
    () => ProtocolsViewModel(
      getProtocolsStream: sl(),
      markProtocolAsRead: sl(),
      isProtocolNew: sl(),
    ),
  );

  sl.registerFactory(
    () => RegisterViewModel(
      registerUC: sl(),
      sendVerifyUC: sl(),
      reloadUserUC: sl(),
    ),
  );

  sl.registerFactory(
    () => AuthViewModel(
      signIn: sl(),
      signOutUC: sl(),
      observe: sl(),
      getCurrent: sl(),
      sendReset: sl(),
    ),
  );

  sl.registerLazySingleton(() => DashboardActionsFactory());
  sl.registerFactory(() => DashboardViewModel(
    factory: sl(),
    findNearestUseCase: sl(),
  ));


  sl.registerFactory<EmergencyReportViewModel>(
  () => EmergencyReportViewModel(
    createReport: sl<CreateEmergencyReport>(),
    fillLocation: sl<FillLocation>(),
    adjustBrightness: sl<AdjustBrightnessFromAmbient>(),
    ambient: sl<AmbientLightService>(),
    screen: sl<ScreenBrightnessService>(),
    openai: sl<OpenAIService>(),
    tts: sl<TtsService>(),
    connectivity: sl<ConnectivityService>(),
  ),
);

  //print('registered: ${sl.allReady()}');
 // print(
  //  'is AdjustBrightnessFromAmbient registered? ${sl.isRegistered<AdjustBrightnessFromAmbient>()}',
  //);
}
