import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';

Future<void> setupFCM() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // request permissions (for iOS and Android 13+)
  final NotificationSettings settings = await messaging.requestPermission(
    
  );
  //print('User granted permission: ${settings.authorizationStatus}');

  // get FCM token
  final String? token = await messaging.getToken();
  //print('FCM Token: $token');

  // listen for foreground messages
  await messaging.subscribeToTopic('alerts');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //print('Received foreground message: ${message.notification?.title}');
    if (message.notification != null) {
      //print('Message also contained a notification: ${message.notification}');
    }
  });

  // handle messages when user taps notification and app is opened from background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //print('Message opened app: ${message.data}');
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

