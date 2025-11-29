// app/app_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/dashboard_viewmodel.dart';
import '../presentation/views/dashboard_screen.dart';
import '../presentation/views/login_screen.dart';
import 'di.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, AuthViewModel vm, __) {
        // router mínimo basado en auth
        if (!vm.isAuthenticated) return const LoginScreen();

        // ✨ NOTA: El RagViewModel ya está disponible globalmente desde main.dart
        // No necesitamos agregarlo aquí porque ya está en el MultiProvider principal
        // Simplemente retornamos el DashboardScreen que tiene acceso al provider

        return const DashboardScreen();
      },
    );
  }
}