// app/di.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// core
import '../helpers/utils/id_generator.dart';
// data - datasources
import '../data/datasources/location_dao.dart';
import '../data/datasources/protocols_firestore_dao.dart';
import '../data/datasources/report_firestore_dao.dart';
import '../data/datasources/report_local_dao.dart';
import '../data/datasources/user_firestore_dao.dart';
import '../data/firebase/training_repository_firebase.dart';
import '../data/repositories/auth_repository.dart';
// data - repositories & implementations
import '../data/repositories/location_repository.dart';
import '../data/repositories/meeting_point_repository.dart';
import '../data/repositories/protocol_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/training_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories_impl/auth_repository_impl.dart';
import '../data/repositories_impl/location_repository_impl.dart';
import '../data/repositories_impl/meeting_point_repository_impl.dart';
import '../data/repositories_impl/protocol_repository_impl.dart';
import '../data/repositories_impl/report_repository_impl.dart';
import '../data/repositories_impl/user_repository_impl.dart';
// external services
import '../data/services_external/ambient_light_service.dart';
import '../data/services_external/connectivity_service.dart';
import '../data/services_external/firebase/auth_service.dart';
import '../data/services_external/firebase/firestore_service.dart';
import '../data/services_external/location/location_service.dart';
// notifications service
import '../data/services_external/notitication_service.dart';
import '../data/services_external/openai_service.dart';
import '../data/services_external/screen_brightness_service.dart';
import '../data/services_external/secure/token_service.dart';
import '../data/services_external/tts_service.dart';
// domain - use cases
import '../domain/use_cases/adjust_brightness_from_ambient.dart';
import '../domain/use_cases/create_emergency_report.dart';
import '../domain/use_cases/get_user_reports.dart';
import '../domain/use_cases/get_user_reports_with_cache.dart';
//dashboard
import '../domain/use_cases/dashboard/find_nearest_meeting_point.dart';
import '../domain/use_cases/fill_location.dart';
import '../domain/use_cases/get_current_user.dart';
import '../domain/use_cases/get_id_token_cache.dart';
import '../domain/use_cases/observe_auth_state.dart';
import '../domain/use_cases/protocols/get_protocols_stream.dart';
import '../domain/use_cases/protocols/is_protocol_new.dart';
import '../domain/use_cases/protocols/mark_protocol_as_read.dart';
import '../domain/use_cases/register_with_email.dart';
import '../domain/use_cases/reload_user.dart';
import '../domain/use_cases/send_email_verification.dart';
import '../domain/use_cases/send_password_reset_email.dart';
import '../domain/use_cases/sign_in_with_email.dart';
import '../domain/use_cases/sign_out.dart';
import '../presentation/navigation/dashboard_actions_factory.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/dashboard_viewmodel.dart';
// presentation - viewmodels & navigation
import '../presentation/viewmodels/emergency_report_viewmodel.dart';
import '../presentation/viewmodels/leaderboard_viewmodel.dart';
import '../presentation/viewmodels/notification_viewmodel.dart';
import '../presentation/viewmodels/reports_list_viewmodel.dart';
import '../presentation/viewmodels/profile_viewmodel.dart';
import '../presentation/viewmodels/protocols_viewmodel.dart';
import '../presentation/viewmodels/register_viewmodel.dart';
import '../presentation/viewmodels/training_viewmodel.dart';

//notifcations with cache and shared preferences
import '../data/cache/notification_cache_manager.dart';
import '../data/database/notification_database.dart';
import '../data/datasources/notification_dao.dart';
import '../data/datasources/report_cache_dao.dart';
import '../data/services_local/notification_preferences_service.dart';
import '../presentation/viewmodels/simple_notification_view_model.dart';

// RAG imports
import '../data/cache/rag_cache.dart';
import '../data/repositories/rag_repository.dart';
import '../data/repositories_impl/rag_repository_impl.dart';
import '../domain/use_cases/get_rag_answer.dart';
import '../presentation/viewmodels/rag_viewmodel.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDi() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

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
  sl.registerLazySingleton<OpenAIService>(() => OpenAIServiceImpl());
  sl.registerLazySingleton<TtsService>(() => TtsServiceImpl());
  sl.registerLazySingleton<ConnectivityService>(
        () => ConnectivityServiceImpl(),
  );

  // Cache DAOs
  sl.registerLazySingleton(() => ReportCacheDao()..init());
  
  // DAOs
  sl.registerLazySingleton(() => ReportFirestoreDao(sl()));
  sl.registerLazySingleton(() => ProtocolsFirestoreDao());
  sl.registerLazySingleton(() => ReportLocalDao()..init());
  sl.registerLazySingleton(() => LocationDao(sl()));
  sl.registerLazySingleton(() => UserFirestoreDao(sl()));

  // Repositories
  sl.registerLazySingleton<ReportRepository>(
        () => ReportRepositoryImpl(
      remoteDao: sl(),
      localDao: sl(),
      cacheDao: sl(),
      connectivity: sl(),
    ),
  );
  sl.registerLazySingleton<LocationRepository>(
        () => LocationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProtocolRepository>(
        () => ProtocolRepositoryImpl(dao: sl(), prefs: prefs),
  );
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<TrainingRepository>(
        () => FirebaseTrainingRepository(),
  );
  sl.registerLazySingleton<MeetingPointRepository>(
        () => MeetingPointRepositoryImpl(),
  );

  // RAG Cache and Repository
  sl.registerLazySingleton<RagCache>(() => RagCache(prefs));
  sl.registerLazySingleton<RagRepository>(
        () => RagRepositoryImpl(cache: sl()),
  );

  // App services / helpers
  sl.registerLazySingleton(() => FirestoreIdGenerator());

  //Use cases - dashboard
  sl.registerFactory(
        () => FindNearestMeetingPoint(locationService: sl(), repository: sl()),
  );

  // Use cases - protocols
  sl.registerFactory(() => GetProtocolsStream(repository: sl()));
  sl.registerFactory(() => MarkProtocolAsRead(repository: sl()));
  sl.registerFactory(() => IsProtocolNew(repository: sl()));

  // Use cases - RAG
  sl.registerFactory(() => GetRagAnswer(repository: sl()));

  // Use cases - reports & location
  sl.registerFactory(() => FillLocation(sl()));
  sl.registerFactory(() => CreateEmergencyReport(sl(), sl()));
  sl.registerFactory(() => GetUserReports(sl()));
  sl.registerFactory(() => GetUserReportsWithCache(sl()));

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

  try {
    sl.registerLazySingleton<AdjustBrightnessFromAmbient>(
          () => AdjustBrightnessFromAmbient(
        sl<AmbientLightService>(),
        sl<ScreenBrightnessService>(),
      ),
    );
  } catch (e) {
    // Error handling
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
  sl.registerLazySingleton(
        () => DashboardViewModel(factory: sl(), findNearestUseCase: sl()),
  );

  sl.registerFactory<EmergencyReportViewModel>(
        () => EmergencyReportViewModel(
      createReport: sl<CreateEmergencyReport>(),
      fillLocation: sl<FillLocation>(),
      adjustBrightness: sl<AdjustBrightnessFromAmbient>(),
      getCurrentUser: sl<GetCurrentUser>(),
      ambient: sl<AmbientLightService>(),
      screen: sl<ScreenBrightnessService>(),
      openai: sl<OpenAIService>(),
      tts: sl<TtsService>(),
      connectivity: sl<ConnectivityService>(),
    ),
  );

  sl.registerFactory<TrainingViewModel>(
        () => TrainingViewModel(repo: sl<TrainingRepository>()),
  );
  
  sl.registerFactory<ReportsListViewModel>(
    () => ReportsListViewModel(
      getUserReports: sl<GetUserReports>(),
      getUserReportsWithCache: sl<GetUserReportsWithCache>(),
      getCurrentUser: sl<GetCurrentUser>(),
    ),
  );

  sl.registerFactory(() => LeaderboardViewModel());

  sl.registerFactory(() => ProfileViewModel(sl<UserRepository>()));

  // RAG ViewModel
  sl.registerFactory(
        () => RagViewModel(
      repository: sl(),
    ),
  );

  // notifications service
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerFactory<NotificationViewModel>(
        () => NotificationViewModel(sl<NotificationService>()),
  );

  // Database
  sl.registerLazySingleton<NotificationDatabase>(
        () => NotificationDatabase.instance,
  );

  // Cache Manager
  sl.registerLazySingleton<NotificationCacheManager>(
        () => NotificationCacheManager(),
  );

  // DAO
  sl.registerLazySingleton<NotificationDao>(
        () => NotificationDao(
      database: sl<NotificationDatabase>(),
      cache: sl<NotificationCacheManager>(),
    ),
  );

  // Preferences
  sl.registerLazySingleton<NotificationPreferencesService>(
        () => NotificationPreferencesService(),
  );

  // ViewModel
  sl.registerFactory<SimpleNotificationViewModel>(
        () => SimpleNotificationViewModel(
      dao: sl<NotificationDao>(),
      preferences: sl<NotificationPreferencesService>(),
    ),
  );
}