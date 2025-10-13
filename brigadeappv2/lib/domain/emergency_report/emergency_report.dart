class EmergencyReport {
  final String id;
  final String description;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final bool isFollowUp;
  final String type;
  final String place;
  final String? userId;
  DateTime? createdAt;

  EmergencyReport({
    required this.id,
    required this.description,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isFollowUp,
    required this.type,
    required this.place,
    required this.userId,
    required this.createdAt,
  });
}