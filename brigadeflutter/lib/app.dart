import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/emergency_report/emergency_report_cubit.dart';
import 'app_view.dart';

class BrigadeApp extends StatelessWidget {
  const BrigadeApp({super.key});

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

    return BlocProvider(
      create: (_) => EmergencyReportCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const AppView(),
      ),
    );
  }
}
