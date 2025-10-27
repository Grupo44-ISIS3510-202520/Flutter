import 'dart:async';
import 'package:brigadeflutter/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/di.dart';
import 'app/app.dart';
import 'package:provider/provider.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/emergency_report_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env'); // optional
  await Hive.initFlutter();

  // initialize firebase if used
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      ],
      child: const MyApp(),
    ),
  );
}