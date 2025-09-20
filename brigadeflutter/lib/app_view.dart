import 'package:flutter/material.dart';
import 'components/app_bottom_nav.dart';
import 'screens/emergency_report_screen.dart';
import 'screens/training_screen.dart';
import 'screens/profile_screen.dart';

/// Contenedor de pestañas con BottomNavigationBar.
/// Usamos IndexedStack para conservar estado por tab.
class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  int _index = 0;

  final _pages = const <Widget>[
    EmergencyReportScreen(), // 0
    TrainingScreen(),        // 1
    _PlaceholderPage('Protocols'),    // 2
    _PlaceholderPage('Alerts'),       // 3
    ProfileScreen(),         // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantiene el estado de cada tab (scroll, forms, etc.).
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) => Center(child: Text('$name (pendiente)'));
}
