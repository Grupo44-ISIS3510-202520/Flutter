import 'package:flutter/material.dart';
import '../presentation/views/emergency_report_view.dart';
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
        return const EmergencyReportScreen(); // reemplaza por tu dashboard/home
      },
    );
  }
}
