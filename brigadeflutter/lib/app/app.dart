import 'package:brigadeflutter/app/app_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/views/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, vm, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Brigade',
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2F6AF6)),
          // el gate decide qué pantalla mostrar según el estado de auth
          home: vm.isAuthenticated ? const AppView() : const LoginScreen(),
          routes: {
            // deja tus rutas extra (register, profile, etc.)
          },
        );
      },
    );
  }
}
