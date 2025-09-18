import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int current;
  const AppBottomNav({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: current,
      onTap: (i) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sección $i próximamente')),
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.local_hospital_outlined), label: 'Emergency'),
        BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Training'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Protocols'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
