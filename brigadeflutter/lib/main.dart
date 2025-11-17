import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'data/repositories/notification_repository.dart';
import 'data/services_external/notitication_service.dart';
import 'firebase_options.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/emergency_report_viewmodel.dart';
import 'presentation/viewmodels/notification_screen_viewmodel.dart'; //este es para el screen de notificaciones
import 'presentation/viewmodels/training_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);

  await dotenv.load();
  await Hive.initFlutter();
  await Hive.openBox('trainingsBox');
  await Hive.openBox<String>('ai_cache');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupDi();

  final navigatorKey = GlobalKey<NavigatorState>();


  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => sl<AuthViewModel>(),
        ),
        ChangeNotifierProvider<EmergencyReportViewModel>(
          create: (_) => sl<EmergencyReportViewModel>(),
        ),
        ChangeNotifierProvider(create: (_) => TrainingViewModel(repo: sl())),
        ChangeNotifierProvider(
          create: (_) => NotificationScreenViewModel(NotificationRepository()),
        ),

        ChangeNotifierProvider<DashboardViewModel>.value(
          value: sl<DashboardViewModel>(),
        ),
      ],
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );

  // After the first frame is drawn, try to init notifications in background.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    (() async {
      final conn = await Connectivity().checkConnectivity();
      final navigatorCtx = navigatorKey.currentContext;
      if (conn == ConnectivityResult.none && navigatorCtx != null) {

        showDialog<void>(
          context: navigatorCtx,
          barrierDismissible: true,
          builder: (dCtx) => AlertDialog(
              title: const Text('No internet'),
              content: const Text(
                'You appear to be offline. Notifications cannot be enabled while offline. You can continue without notifications or try again when online.',
              ),
              // persistent modal
              actions: [
                TextButton(
                  onPressed: () {
                    // replace dialog with a non-blocking MaterialBanner so user can continue
                    Navigator.of(dCtx).pop();
                    final ctx = navigatorKey.currentContext;
                    if (ctx == null) return;
                    ScaffoldMessenger.of(ctx).showMaterialBanner(
                      MaterialBanner(
                        content: const Text('Notifications disabled — you can retry from here.'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              ScaffoldMessenger.of(ctx).clearMaterialBanners();
                              final ok = await sl<NotificationService>().init();
                              if (ok) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text('Notifications enabled')),
                                );
                              } else {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text('Failed to enable notifications')),
                                );
                              }
                            },
                            child: const Text('Retry'),
                          ),
                          TextButton(
                            onPressed: () => ScaffoldMessenger.of(ctx).clearMaterialBanners(),
                            child: const Text('Dismiss'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Continue'),
                ),
                TextButton(
                  onPressed: () async {

                    final retryCtx = navigatorKey.currentContext;
                    if (retryCtx == null) return;

                    showDialog<void>(
                      context: retryCtx,
                      barrierDismissible: false,
                      builder: (pCtx) => const Center(child: CircularProgressIndicator()),
                    );
                    final ok = await sl<NotificationService>().init();
                    Navigator.of(retryCtx).pop(); // remove progress
                    if (ok) {
                      ScaffoldMessenger.of(retryCtx).showSnackBar(
                        const SnackBar(content: Text('Notifications enabled')),
                      );
                      Navigator.of(dCtx).pop();
                    } else {
                      showDialog<void>(
                        context: dCtx,
                        barrierDismissible: true,
                        builder: (fCtx) => AlertDialog(
                          title: const Text('Still not available'),
                          content: const Text('Notifications could not be enabled. Try again later.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(fCtx).pop(), child: const Text('OK')),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
        );
        return; // don't attempt init now
      }

      try {
        final ok = await sl<NotificationService>().init();
        if (!ok) {
          final ctx = navigatorKey.currentContext;
          if (ctx == null) return;
          showDialog<void>(
            context: ctx,
            barrierDismissible: true,
            builder: (dCtx) => AlertDialog(
              title: const Text('Notifications not available'),
              content: const Text(
                'We could not enable push notifications right now. You can continue using the app without notifications or try again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dCtx).pop(),
                  child: const Text('Continue'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(dCtx).pop();
                    final retryCtx = navigatorKey.currentContext;
                    if (retryCtx == null) return;
                    final retryOk = await sl<NotificationService>().init();
                    if (retryOk) {
                      ScaffoldMessenger.of(retryCtx).showSnackBar(
                        const SnackBar(content: Text('Notifications enabled')),
                      );
                    } else {
                      ScaffoldMessenger.of(retryCtx).showSnackBar(
                        const SnackBar(content: Text('Failed to enable notifications')),
                      );
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;
        showDialog<void>(
          context: ctx,
          barrierDismissible: true,
          builder: (dCtx) => AlertDialog(
            title: const Text('Notifications not available'),
            content: Text('Failed to initialize notifications: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dCtx).pop(),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    })();
  });
}
