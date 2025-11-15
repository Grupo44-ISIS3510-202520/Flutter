import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// viewmodels
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/emergency_report_viewmodel.dart';
import '../presentation/viewmodels/leaderboard_viewmodel.dart';
import '../presentation/viewmodels/profile_viewmodel.dart';
import '../presentation/viewmodels/protocols_viewmodel.dart';
import '../presentation/viewmodels/register_viewmodel.dart';
import '../presentation/viewmodels/training_viewmodel.dart';
import '../presentation/views/dashboard_screen.dart';
import '../presentation/views/emergency_report_view.dart';
import '../presentation/views/leaderboard_screen.dart';
// views
import '../presentation/views/login_screen.dart';
import '../presentation/views/notifications_screen.dart';
import '../presentation/views/profile_view.dart';
import '../presentation/views/protocols_screen.dart';
import '../presentation/views/register_screen.dart';
import '../presentation/views/training_screen.dart';
// di
import 'di.dart' show sl;

// route names
const String routeDashboard = '/dashboard';
const String routeTraining = '/training';
const String routeProtocols = '/protocols';
const String routeNotifications = '/notification';
const String routeProfile = '/profile';
const String routeLogin = '/login';
const String routeRegister = '/register';
const String routeReport = '/report';
const String routeLeaderboard = '/leaderboard';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, AuthViewModel auth, __) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Brigade',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2F6AF6),
          ),

          home: auth.isAuthenticated ? const DashboardScreen() : const LoginScreen(),

          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case routeLogin:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => const LoginScreen(),
                );

              case routeRegister:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => sl<RegisterViewModel>(),
                    child: const RegisterScreen(),
                  ),
                );

              case routeDashboard:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => const DashboardScreen(),
                );

              case routeReport:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) {
                      final EmergencyReportViewModel vm = sl<EmergencyReportViewModel>();
                      WidgetsBinding.instance.addPostFrameCallback(
                            (_) => vm.initBrightness(),
                      );
                      return vm;
                    },
                    child: const EmergencyReportScreen(),
                  ),
                );

              case routeProtocols:
                return MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => sl<ProtocolsViewModel>(),
                    child: const _ProtocolsScreenWithInit(),
                  ),
                  settings: settings,
                );

              case routeTraining:
                return MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => sl<TrainingViewModel>()..load(),
                    child: const TrainingScreen(),
                  ),
                  settings: settings,
                );

              case routeNotifications:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => const NotificationsScreen(),
                );

              case routeProfile:
                return MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) {
                      final ProfileViewModel vm = sl<ProfileViewModel>();
                      final User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        vm.load(user.uid);
                      }
                      return vm;
                    },
                    child: const ProfileView(),
                  ),
                  settings: settings,
                );

              case routeLeaderboard:
                return MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => LeaderboardViewModel()..loadLeaderboard(),
                    child: const LeaderboardScreen(),
                  ),
                  settings: settings,
                );

              default:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => auth.isAuthenticated ? const DashboardScreen() : const LoginScreen(),
                );
            }
          },
        );
      },
    );
  }
}

class _ProtocolsScreenWithInit extends StatefulWidget {
  const _ProtocolsScreenWithInit();

  @override
  State<_ProtocolsScreenWithInit> createState() =>
      _ProtocolsScreenWithInitState();
}

class _ProtocolsScreenWithInitState extends State<_ProtocolsScreenWithInit> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProtocolsViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) => const ProtocolsScreen();
}
