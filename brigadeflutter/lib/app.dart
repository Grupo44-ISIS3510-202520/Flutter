import 'package:brigadeflutter/blocs/training/training_cubit.dart';
import 'package:brigadeflutter/blocs/training/training_repository.dart';
import 'package:brigadeflutter/screens/profile_screen.dart';
import 'package:brigadeflutter/screens/training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/profile/profile_cubit.dart';
import 'blocs/profile/profile_repository.dart';

import 'app_view.dart';
import 'screens/notifications_screen.dart';
import 'screens/emergency_dashboard_screen.dart';
import 'screens/protocols_and_manuals_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'blocs/auth/auth_cubit.dart';
import 'screens/login_screen.dart';

// GPS + Repo de reportes
import 'services/location_service.dart';
import 'domain/repositories/report_repository.dart';
import 'data/firebase/report_repository_firebase.dart';
import 'blocs/emergency_report/emergency_report_cubit.dart';

class BrigadeApp extends StatelessWidget {
  const BrigadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6AF6)),
      scaffoldBackgroundColor: Colors.white,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFF3F5F8),
        selectedItemColor: Color(0xFF2F6AF6),
        unselectedItemColor: Color(0xFF8E98A8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF3F5F8),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocationService>(create: (_) => LocationService()),
        RepositoryProvider<ReportRepository>(create: (_) => FirebaseReportRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit()),
          BlocProvider(
            create: (ctx) => EmergencyReportCubit(
              ctx.read<LocationService>(),
              ctx.read<ReportRepository>(),
            ),
          ),
          BlocProvider(create: (_) => ProfileCubit(InMemoryProfileRepository())..load()),
          BlocProvider(create: (_) => TrainingCubit(InMemoryTrainingRepository())..load()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,

          // Auth Gate
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return snap.data == null
                  ? const LoginScreen()
                  : const EmergencyDashboardScreen();
            },
          ),

          routes: {
            '/login': (context) => const LoginScreen(),
            '/report': (context) => const AppView(), // devuelve EmergencyReportScreen
            '/notification': (context) => const NotificationsScreen(),
            '/dashboard': (context) => const EmergencyDashboardScreen(),
            '/protocols': (context) => const ProtocolsAndManualsScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/training': (context) => const TrainingScreen(),
          },
        ),
      ),
    );
  }
}
