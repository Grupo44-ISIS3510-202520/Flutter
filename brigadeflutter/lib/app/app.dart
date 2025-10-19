import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/di.dart' show sl;
import '../presentation/viewmodels/emergency_report_viewmodel.dart';
import '../presentation/views/emergency_report_view.dart';

const routeDashboard     = '/dashboard';
const routeTraining      = '/training';
const routeProtocols     = '/protocols';
const routeNotifications = '/notification';
const routeProfile       = '/profile';
const routeLogin         = '/login';
const routeReport        = '/report';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brigade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2F6AF6),
      ),
      initialRoute: routeDashboard,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case routeReport:
            return MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => EmergencyReportViewModel(
                  createReport: sl(),// CreateEmergencyReport
                  fillLocation: sl(),// FillLocation
                ),
                child: const EmergencyReportScreen(),
              ),
              settings: settings,
            );

          case routeDashboard:
          case routeTraining:
          case routeProtocols:
          case routeNotifications:
          case routeProfile:
          case routeLogin:
            return MaterialPageRoute(
              builder: (_) => _PlaceholderScreen(title: settings.name ?? 'screen'),
              settings: settings,
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const _PlaceholderScreen(title: 'Not found'),
              settings: settings,
            );
        }
      },
    );
  }
}

// pantalla temporal para rutas no migradas
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ruta: $title'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(routeReport),
              child: const Text('ir a Emergency Report'),
            ),
          ],
        ),
      ),
    );
  }
}
