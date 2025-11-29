import '../entities/report.dart';

class ReportModel {
  const ReportModel({
    required this.reportId,
    required this.type,
    required this.description,
    required this.isFollowUp,
    required this.timestampMs,
    required this.elapsedTime,
    required this.place,
    this.latitude,
    this.longitude,
    this.audioUrl,
    this.imageUrl,
    required this.uiid,
    required this.userId,
  });
  
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final ts = json['timestamp'];
    final ms = ts is String
        ? DateTime.parse(ts).millisecondsSinceEpoch
        : (json['timestampMs'] ?? DateTime.now().millisecondsSinceEpoch);
    return ReportModel(
      reportId: json['reportId'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      isFollowUp: json['isFollowUp'] ?? false,
      timestampMs: ms is int ? ms : DateTime.now().millisecondsSinceEpoch,
      elapsedTime: json['elapsedTime'] ?? 0,
      place: json['place'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      uiid: json['uiid'] ?? 0,
      userId: json['userId'] ?? '',
    );
  }
  
  factory ReportModel.fromEntity(Report e) => ReportModel(
    reportId: e.reportId,
    type: e.type,
    description: e.description,
    isFollowUp: e.isFollowUp,
    timestampMs: e.timestamp.millisecondsSinceEpoch,
    elapsedTime: e.elapsedTime,
    place: e.place,
    latitude: e.latitude,
    longitude: e.longitude,
    audioUrl: e.audioUrl,
    imageUrl: e.imageUrl,
    uiid: e.uiid,
    userId: e.userId,
  );
  
  final String reportId; // F## or K##
  final String type;
  final String description;
  final bool isFollowUp;
  final int timestampMs;
  final int elapsedTime; // ms or s
  final String place;
  final double? latitude;
  final double? longitude;
  final String? audioUrl;
  final String? imageUrl;
  final int uiid;
  final String userId;

  Report toEntity() => Report(
    reportId: reportId,
    type: type,
    description: description,
    isFollowUp: isFollowUp,
    timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
    elapsedTime: elapsedTime,
    place: place,
    latitude: latitude,
    longitude: longitude,
    audioUrl: audioUrl,
    imageUrl: imageUrl,
    uiid: uiid,
    userId: userId,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'reportId': reportId,
    'type': type,
    'description': description,
    'isFollowUp': isFollowUp,
    'timestamp': DateTime.fromMillisecondsSinceEpoch(timestampMs).toIso8601String(),
    'elapsedTime': elapsedTime,
    'place': place,
    'latitude': latitude,
    'longitude': longitude,
    'audioUrl': audioUrl,
    'imageUrl': imageUrl,
    'uiid': uiid,
    'userId': userId,
  };
}
