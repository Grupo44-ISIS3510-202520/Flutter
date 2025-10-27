import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/di.dart' show sl;

// presentation
import '../presentation/views/login_screen.dart';
import 'package:brigadeflutter/app/app_view.dart';
import '../presentation/views/emergency_report_view.dart';
import '../presentation/views/protocols_screen.dart';

// viewmodels
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/emergency_report_viewmodel.dart';
import '../presentation/viewmodels/protocols_viewmodel.dart';
import '../presentation/views/register_screen.dart';
import '../presentation/viewmodels/register_viewmodel.dart';

// rutas públicas
const routeDashboard = '/dashboard';
const routeTraining = '/training';
const routeProtocols = '/protocols';
const routeNotifications = '/notification';
const routeProfile = '/profile';
const routeLogin = '/login';
const routeReport = '/report';
const routeRegister = '/register';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, vm, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Brigade',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2F6AF6),
          ),
          // auth gate: decide pantalla inicial según estado de sesión
          home: vm.isAuthenticated ? const AppView() : const LoginScreen(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case routeReport:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => EmergencyReportViewModel(
                      createReport: sl(), // CreateEmergencyReport
                      fillLocation: sl(), // FillLocation
                    ),
                    child: const EmergencyReportScreen(),
                  ),
                );

              case routeProtocols:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => ChangeNotifierProvider(
                    // crea vm y dispara init inmediatamente
                    create: (_) {
                      final vm = sl<ProtocolsViewModel>();
                      Future.microtask(vm.init);
                      return vm;
                    },
                    child: const ProtocolsScreen(),
                  ),
                );

              // opcionales: redirigen al shell principal; AppView maneja el bottom nav
              case routeDashboard:
              case routeTraining:
              case routeNotifications:
              case routeProfile:
              case routeLogin:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => vm.isAuthenticated
                      ? const AppView()
                      : const LoginScreen(),
                );
              case routeRegister: // <-- nueva
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => sl<RegisterViewModel>(),
                    child: const RegisterScreen(),
                  ),
                );
              default:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => vm.isAuthenticated
                      ? const AppView()
                      : const LoginScreen(),
                );
            }
          },
        );
      },
    );
  }
}
