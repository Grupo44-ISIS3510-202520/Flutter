import 'package:brigadeflutter/presentation/viewmodels/training_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// di
import 'di.dart' show sl;

// viewmodels
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/register_viewmodel.dart';
import '../presentation/viewmodels/dashboard_viewmodel.dart';
import '../presentation/viewmodels/emergency_report_viewmodel.dart';
import '../presentation/viewmodels/protocols_viewmodel.dart';

// views
import '../presentation/views/login_screen.dart';
import '../presentation/views/register_screen.dart';
import '../presentation/views/dashboard_screen.dart';
import '../presentation/views/emergency_report_view.dart';
import '../presentation/views/protocols_screen.dart';
import '../presentation/views/profile_view.dart';
import '../presentation/views/training_screen.dart';
import '../presentation/views/notifications_screen.dart';

// route names
const routeDashboard = '/dashboard';
const routeTraining = '/training';
const routeProtocols = '/protocols';
const routeNotifications = '/notification';
const routeProfile = '/profile';
const routeLogin = '/login';
const routeRegister = '/register';
const routeReport = '/report';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, auth, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Brigade',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2F6AF6),
          ),

          // auth gate: first screen after login is the dashboard
          home: auth.isAuthenticated
              ? ChangeNotifierProvider(
                  create: (_) => sl<DashboardViewModel>(),
                  child: const DashboardScreen(),
                )
              : const LoginScreen(),

          onGenerateRoute: (settings) {
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
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => sl<DashboardViewModel>(),
                    child: const DashboardScreen(),
                  ),
                );

              case routeReport:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) {
                      final vm = sl<EmergencyReportViewModel>();
                      // init post-frame para no notificar durante build
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
                  builder: (_) =>
                      const ProtocolsScreen(), // stub until MVVM added
                );

              case routeProfile:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) =>
                      const ProtocolsScreen(), // stub until MVVM added
                );

              default:
                // fallback to the gate
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => auth.isAuthenticated
                      ? ChangeNotifierProvider(
                          create: (_) => sl<DashboardViewModel>(),
                          child: const DashboardScreen(),
                        )
                      : const LoginScreen(),
                );
            }
          },
        );
      },
    );
  }
}

class _ProtocolsScreenWithInit extends StatefulWidget {
  const _ProtocolsScreenWithInit({Key? key}) : super(key: key);

  @override
  State<_ProtocolsScreenWithInit> createState() =>
      _ProtocolsScreenWithInitState();
}

class _ProtocolsScreenWithInitState extends State<_ProtocolsScreenWithInit> {
  @override
  void initState() {
    super.initState();
    // inicializa el ViewModel correctamente una vez montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProtocolsViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) => const ProtocolsScreen();
}
