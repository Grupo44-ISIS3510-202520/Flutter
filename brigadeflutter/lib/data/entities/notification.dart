import 'package:equatable/equatable.dart';

/// Domain entity representing a notification
/// Matches Firestore document structure: message, timestamp, title, type
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, message, type, timestamp, isRead];
}
