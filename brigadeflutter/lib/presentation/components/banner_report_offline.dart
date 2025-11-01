import 'package:flutter/material.dart';

class OfflineMaterialBanner extends StatelessWidget {
  const OfflineMaterialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      leading: const Icon(Icons.signal_wifi_off, color: Colors.black87),
      content: const Text(
        'You are offline. Reports will be saved locally and sent when you are back online.',
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFFFF4E5),
      actions: [
        TextButton(
          onPressed: () => ScaffoldMessenger.of(context).clearMaterialBanners(),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}

