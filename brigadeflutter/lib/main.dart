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
import 'presentation/viewmodels/dashboard_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Hive.openBox('trainingsBox');
  await Hive.openBox<String>('ai_cache');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupDi();
  print('GetIt hash in main.dart: ${sl.hashCode}');

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


        ChangeNotifierProvider<DashboardViewModel>.value(
          value: sl<DashboardViewModel>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}