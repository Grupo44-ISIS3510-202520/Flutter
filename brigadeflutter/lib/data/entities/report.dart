class Report {
  const Report({
    required this.id,
    required this.type,
    required this.placeTime,
    required this.description,
    required this.isFollowUp,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });
  final int id;
  final String type;
  final String placeTime;
  final String description;
  final bool isFollowUp;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
}
