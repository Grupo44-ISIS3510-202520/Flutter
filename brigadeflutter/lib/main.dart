import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/adapters.dart';
import 'presentation/viewmodels/emergency_report_viewmodel.dart';
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:brigadeflutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await setupDi();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EmergencyReportViewModel(
            createReport: sl(),
            fillLocation: sl(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

