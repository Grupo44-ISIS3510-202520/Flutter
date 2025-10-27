import 'package:brigadeflutter/domain/use_cases/send_password_reset_email.dart';
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
import '../data/repositories/location_repository.dart';
import '../domain/use_cases/fill_location.dart';
import '../data/datasources/user_firestore_dao.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories_impl/user_repository_impl.dart';
import '../data/services_external/secure/token_service.dart';

import '../domain/use_cases/register_with_email.dart';
import '../domain/use_cases/send_email_verification.dart';
import '../domain/use_cases/reload_user.dart';
import '../domain/use_cases/get_id_token_cache.dart';

import '../presentation/viewmodels/register_viewmodel.dart';

import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services_external/firebase/auth_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories_impl/auth_repository_impl.dart';
import '../domain/use_cases/sign_in_with_email.dart';
import '../domain/use_cases/observe_auth_state.dart';
import '../domain/use_cases/get_current_user.dart';
import '../domain/use_cases/sign_out.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  // external services
  sl.registerLazySingleton(() => FirestoreService());
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton(() => AuthService(auth: FirebaseAuth.instance));

  // dao
  sl.registerLazySingleton(() => ReportFirestoreDao(sl()));
  sl.registerLazySingleton(() => ReportLocalDao()..init());
  sl.registerLazySingleton(() => LocationDao(sl()));

  // repos
  sl.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(remote: sl(), local: sl()));
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // app services
  sl.registerFactory(() => FillLocation(sl()));
  sl.registerLazySingleton(() => FirestoreIdGenerator());
  sl.registerFactory(() => CreateEmergencyReport(sl(), sl()));

  sl.registerLazySingleton(() => UserFirestoreDao(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  sl.registerLazySingleton(() => TokenService());

  sl.registerFactory(() => RegisterWithEmail(sl(), sl()));
  sl.registerFactory(() => SendEmailVerification(sl()));
  sl.registerFactory(() => ReloadUser(sl()));
  sl.registerFactory(() => GetIdTokenCached(sl(), sl()));
  sl.registerFactory(() => SignInWithEmail(sl()));
  sl.registerFactory(() => ObserveAuthState(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
  sl.registerFactory(() => SignOut(sl()));

  sl.registerFactory(() => RegisterViewModel(
    registerUC: sl(),
    sendVerifyUC: sl(),
    reloadUserUC: sl(),
  ));


  sl.registerFactory(() => SendPasswordResetEmail(sl()));

  sl.registerFactory(() => AuthViewModel(
        signIn: sl(),
        signOutUC: sl(),
        observe: sl(),
        getCurrent: sl(),
        sendReset: sl(),
      ));
}