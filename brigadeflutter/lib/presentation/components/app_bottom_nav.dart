import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current});
  final int current;

  void _go(BuildContext context, String route) {
    // evita recrear la misma ruta
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      // fondo menos blanco con sombra y borde superior
      decoration: BoxDecoration(
        color: cs.surface, // integra con tema
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // sombra suave
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0x1F000000)), // hairline
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: cs.surface,
          elevation: 0,
          selectedItemColor: cs.primary,
          unselectedItemColor: cs.onSurfaceVariant,
          currentIndex: current,
          onTap: (i) {
            switch (i) {
              case 0:
                _go(context, '/dashboard');
                break;
              case 1:
                _go(context, '/training');
                break;
              case 2:
                _go(context, '/protocols');
                break; // conectado
              case 3:
                _go(context, '/notification');
                break;
              case 4:
                _go(context, '/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              label: 'Training',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: 'Protocols',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.notifications_none),
            //   label: 'Notifications',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
