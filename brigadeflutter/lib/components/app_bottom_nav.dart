import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int current;
  const AppBottomNav({super.key, required this.current});

  void _go(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: current,
      onTap: (i) {
        switch (i) {
          case 0: _go(context, '/report'); break;
          case 1: ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training soon'))); break;
          case 2: _go(context, '/protocols'); break;
          case 3: _go(context, '/notification'); break;
          case 4: _go(context, '/profile'); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.local_hospital_outlined), label: 'Emergency report'),
        BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Training'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Protocols'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifications'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
