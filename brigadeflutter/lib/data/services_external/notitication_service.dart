import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
class NotificationService {
  static const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
  'alerts_channel',
  'Alerts',
  importance: Importance.max,
);
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'alerts_channel', // id
    'Alertas importantes', // nombre
    description: 'Canal para notificaciones críticas',
    importance: Importance.high,
  );

  Future<void> init() async {
    await Firebase.initializeApp();

    final NotificationSettings settings = await _messaging.requestPermission();
    // debug: print permission and token
    // ignore: avoid_print
    print('FCM permission: ${settings.authorizationStatus}');

    final String? token = await _messaging.getToken();
    // ignore: avoid_print
    print('FCM Token: $token');

    // subscribe to topic used by the backend
    try {
      await _messaging.subscribeToTopic('alerts');
      // ignore: avoid_print
      print('Subscribed to topic: alerts');
    } catch (e) {
      // ignore: avoid_print
      print('Failed to subscribe to topic: $e');
    }

    // crear canal de Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // configuración inicial de plugin
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // registrar manejador de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      // ignore: avoid_print
      //print('Foreground message received: ${msg.notification?.title} - ${msg.notification?.body}');
      _handleForegroundMessage(msg);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      // ignore: avoid_print
      //print('User opened app from notification: ${msg.data}');
    });
  }

  // handler de mensajes en background
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
  }

  // escucha mensajes en foreground
  void listenForeground(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    if (notification != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'alerts_channel',
        'Alerts',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
      );
    }
  }
}
