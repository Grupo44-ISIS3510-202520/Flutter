import 'package:brigadeflutter/app/di.dart';
import 'package:brigadeflutter/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:brigadeflutter/presentation/views/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/views/login_screen.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, vm, __) {
        // router mínimo basado en auth
        if (!vm.isAuthenticated) return const LoginScreen();
        // return const EmergencyReportScreen();
        ChangeNotifierProvider(
          create: (_) => sl<DashboardViewModel>(),
          child: const DashboardScreen(),
        );
        return const DashboardScreen();
      },
    );
  }
}
