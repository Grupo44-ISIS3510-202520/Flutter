import '../entities/report.dart';

class ReportModel {
  factory ReportModel.fromJson(Map<String, dynamic> json, {required int id}) {
    final ts = json['createdAt'];
    final ms = ts is DateTime
        ? ts.millisecondsSinceEpoch
        : (json['createdAtMs'] ?? 0);
    return ReportModel(
      id: id,
      type: json['type'] ?? '',
      placeTime: json['placeTime'] ?? '',
      description: json['description'] ?? '',
      isFollowUp: json['isFollowUp'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAtMs: ms is int ? ms : 0,
    );
  }
  factory ReportModel.fromEntity(Report e) => ReportModel(
    id: e.id,
    type: e.type,
    placeTime: e.placeTime,
    description: e.description,
    isFollowUp: e.isFollowUp,
    latitude: e.latitude,
    longitude: e.longitude,
    createdAtMs: e.createdAt.millisecondsSinceEpoch,
  );
  const ReportModel({
    required this.id,
    required this.type,
    required this.placeTime,
    required this.description,
    required this.isFollowUp,
    this.latitude,
    this.longitude,
    required this.createdAtMs,
  });
  final int id;
  final String type;
  final String placeTime;
  final String description;
  final bool isFollowUp;
  final double? latitude;
  final double? longitude;
  final int createdAtMs;

  Report toEntity() => Report(
    id: id,
    type: type,
    placeTime: placeTime,
    description: description,
    isFollowUp: isFollowUp,
    latitude: latitude,
    longitude: longitude,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
  );

  Map<String, dynamic> toJson() => {
    'reportId': id,
    'type': type,
    'placeTime': placeTime,
    'description': description,
    'isFollowUp': isFollowUp,
    'latitude': latitude,
    'longitude': longitude,
    'createdAt': DateTime.fromMillisecondsSinceEpoch(createdAtMs),
  };
}
