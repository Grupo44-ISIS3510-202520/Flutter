class Report {
  const Report({
    required this.reportId,
    required this.type,
    required this.description,
    required this.isFollowUp,
    required this.timestamp,
    required this.elapsedTime,
    required this.place,
    this.latitude,
    this.longitude,
    this.audioUrl,
    this.imageUrl,
    required this.uiid,
    required this.userId,
  });
  final String reportId; // F## or K##
  final String type;
  final String description;
  final bool isFollowUp;
  final DateTime timestamp; // ISO 8601
  final int elapsedTime; // ms or s
  final String place;
  final double? latitude;
  final double? longitude;
  final String? audioUrl;
  final String? imageUrl;
  final int uiid;
  final String userId; // UUID of user creating the report
}
