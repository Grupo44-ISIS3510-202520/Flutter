import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {

  factory NotificationModel.fromFirestore(Map<String, dynamic> data) {
    return NotificationModel(
      title: data['title'] ?? '',
      message: data['message'] ?? '',
     timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] ?? '',
    );
  }

  NotificationModel({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
  });
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
}
