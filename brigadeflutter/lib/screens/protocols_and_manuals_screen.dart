import 'package:flutter/material.dart';
import '../components/app_bottom_nav.dart';

class ProtocolsAndManualsScreen extends StatelessWidget {
  const ProtocolsAndManualsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final protocols = [
      {
        'icon': Icons.local_fire_department,
        'color': Colors.red,
        'title': 'Fire Emergency',
        'subtitle': 'Fire safety procedures',
      },
      {
        'icon': Icons.warning, 
        'color': Colors.orange,
        'title': 'Earthquake Emergency',
        'subtitle': 'Earthquake safety measures',
      },
      {
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'title': 'Flood Emergency',
        'subtitle': 'Flood response guidelines',
      },
      {
        'icon': Icons.favorite,
        'color': Colors.pink,
        'title': 'Medical Emergency',
        'subtitle': 'Medical emergency protocols',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Protocols & Manuals"),
        centerTitle: true,
      ),
      bottomNavigationBar: const AppBottomNav(current: 2),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [

            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search protocols...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: protocols.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final p = protocols[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (p['color'] as Color).withOpacity(0.2),
                      child: Icon(
                        p['icon'] as IconData,
                        color: p['color'] as Color,
                      ),
                    ),
                    title: Text(p['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(p['subtitle'] as String),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
