import 'package:flutter/material.dart';

enum NotificationType { critical, medical, security, reminder, general }

class AppNotification {
  final String title;
  final String subtitle;
  final String timeLabel;
  final NotificationType type;

  const AppNotification({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.type,
  });

  (IconData, Color) get visual {
    switch (type) {
      case NotificationType.critical:
        return (Icons.error_outline, const Color(0xFFE74C3C));
      case NotificationType.medical:
        return (Icons.healing_outlined, const Color(0xFF2ECC71));
      case NotificationType.security:
        return (Icons.shield_outlined, const Color(0xFF3498DB));
      case NotificationType.reminder:
        return (Icons.campaign_outlined, const Color(0xFF6C5CE7));
      case NotificationType.general:
        return (Icons.info_outline, const Color(0xFF95A5A6));
    }
  }
}
