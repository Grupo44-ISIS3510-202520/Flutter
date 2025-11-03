import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // request permissions (for iOS and Android 13+)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // get FCM token
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  // listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received foreground message: ${message.notification?.title}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  // handle messages when user taps notification and app is opened from background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message opened app: ${message.data}');
  });
}