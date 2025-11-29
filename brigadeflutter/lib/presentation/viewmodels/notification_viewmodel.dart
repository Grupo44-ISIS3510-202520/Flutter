import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../data/services_external/notitication_service.dart';

class NotificationViewModel extends ChangeNotifier {

  NotificationViewModel(this._service);
  final NotificationService _service;
  String? _lastMessage;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  
  String? get lastMessage => _lastMessage;

  Future<void> init() async {
    await _service.init();

    // escucha mensajes cuando app está abierta
    _service.listenForeground((RemoteMessage message) {
      _lastMessage = message.notification?.title ?? 'Mensaje sin título';
      notifyListeners();
    });
  }

    @override
  void dispose() {
    _foregroundSub?.cancel();
    super.dispose();
  }
}
