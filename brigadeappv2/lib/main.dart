//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:brigadeappv2/ui/core/themes/colors.dart';
import 'package:brigadeappv2/ui/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  //await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  runApp(const BrigadeApp());
}

class BrigadeApp extends StatelessWidget {
  const BrigadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brigade',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // awareness del sistema
      home: const DemoScreen(),
    );
  }
}

//borrar después
class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.extras;

    return Scaffold(
      appBar: AppBar(title: const Text('Demo colores')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Botón primario'),
              subtitle: Text('primary ${c.primary.value.toRadixString(16)}'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Submit report'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: x.dangerPastel,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              'Fire alarm banner',
              style: TextStyle(
                color: c.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
