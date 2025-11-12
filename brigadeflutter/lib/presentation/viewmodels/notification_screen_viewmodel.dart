import 'package:flutter/material.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/models/notification_model.dart';

class NotificationScreenViewModel extends ChangeNotifier {

  NotificationScreenViewModel(this._repository);

  final NotificationRepository _repository;

  Stream<List<NotificationModel>> get notificationsStream {
    return _repository.getAlerts();
  }
}
