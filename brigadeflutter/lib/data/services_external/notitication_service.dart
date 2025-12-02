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

  /// Initialize notifications. Returns true when initialization succeeded
  /// enough to receive notifications (i.e. we obtained a token).
  /// Initialize notifications. Returns true when initialization succeeded
  /// enough to receive notifications (i.e. we obtained a token).
  ///
  /// [timeout] bounds how long we wait for token retrieval and topic
  /// subscription. If any of those steps time out, init returns false.
  Future<bool> init({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      await Firebase.initializeApp();

      final NotificationSettings settings = await _messaging.requestPermission();
      // debug: print permission and token
      // ignore: avoid_print
      print('FCM permission: ${settings.authorizationStatus}');

      // try to obtain a token but don't wait indefinitely
      String? token;
      try {
        token = await _messaging.getToken().timeout(timeout);
      } catch (_) {
        token = null;
      }
      // ignore: avoid_print
      print('FCM Token: $token');

      // If we couldn't get a token, consider initialization failed (likely offline)
      if (token == null) return false;

      // subscribe to topic used by the backend (bounded)
      try {
        await _messaging.subscribeToTopic('alerts').timeout(timeout);
        // ignore: avoid_print
        print('Subscribed to topic: alerts');
      } catch (e) {
        // ignore: avoid_print
        print('Failed to subscribe to topic: $e');
      }

      // crear canal de Android para alertas
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
      
      // crear canal para sincronización de reportes
      const AndroidNotificationChannel syncChannel = AndroidNotificationChannel(
        'report_sync_channel',
        'Report Sync',
        description: 'Notifications for successfully synced offline reports',
        importance: Importance.high,
      );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(syncChannel);

      // configuración inicial de plugin
      const InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // registrar manejador de background
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
        _handleForegroundMessage(msg);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {});

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('NotificationService.init failed: $e');
      return false;
    }
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
  
  /// Show a local notification for a synced report
  Future<void> showReportSyncedNotification({
    required String reportId,
    required DateTime timestamp,
  }) async {
    try {
      // ignore: avoid_print
      print('NotificationService: Showing sync notification for report $reportId');
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'report_sync_channel',
        'Report Sync',
        channelDescription: 'Notifications for successfully synced offline reports',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );
      
      final String formattedTime = '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
      
      await _flutterLocalNotificationsPlugin.show(
        reportId.hashCode,
        'Report Synced Successfully',
        'Report sent at $formattedTime has been synced with ID: $reportId',
        notificationDetails,
      );
      
      // ignore: avoid_print
      print('NotificationService: Notification displayed successfully');
    } catch (e) {
      // ignore: avoid_print
      print('Error showing sync notification: $e');
    }
  }
}
