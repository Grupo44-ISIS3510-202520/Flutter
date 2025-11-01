import 'package:brigadeflutter/presentation/viewmodels/training_viewmodel.dart';
import 'dart:async';
import 'package:brigadeflutter/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/di.dart';
import 'app/app.dart';
import 'package:provider/provider.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/emergency_report_viewmodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await dotenv.load(fileName: '.env'); // optional
  await Hive.initFlutter();
  await Hive.openBox('trainingsBox');
  await Hive.openBox<String>('ai_cache'); //register box for openai cache

  // initialize firebase if used
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //Firebase.instance.setPersistenceEnabled(true);

  // IMPORTANT: register services before widgets ask for them
  await setupDi();
  print('GetIt hash in main.dart: ${sl.hashCode}');

  // // Better visibility for uncaught errors
  // FlutterError.onError = (details) {
  //   FlutterError.dumpErrorToConsole(details);
  // };
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => sl<AuthViewModel>(),
        ),
        ChangeNotifierProvider<EmergencyReportViewModel>(
          create: (_) => sl<EmergencyReportViewModel>(),
        ),
        ChangeNotifierProvider(create: (_) => TrainingViewModel(repo: sl())),
      ],
      child: const MyApp(),
    ),
  );
}
