import 'package:flutter/material.dart';
import 'screens/emergency_report_screen.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6AF6)),
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const EmergencyReportScreen(),
    );
  }
}
