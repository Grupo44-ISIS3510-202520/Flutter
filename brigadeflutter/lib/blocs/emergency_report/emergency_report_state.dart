import 'package:equatable/equatable.dart';

class EmergencyReportState extends Equatable {
  final String protocolQuery;
  final String type;
  final String placeTime;
  final String description;
  final bool isFollowUp;
  final bool submitting;

  // NUEVO:
  final double? latitude;
  final double? longitude;

  const EmergencyReportState({
    this.protocolQuery = '',
    this.type = '',
    this.placeTime = '',
    this.description = '',
    this.isFollowUp = false,
    this.submitting = false,
    this.latitude,
    this.longitude,
  });

  EmergencyReportState copyWith({
    String? protocolQuery,
    String? type,
    String? placeTime,
    String? description,
    bool? isFollowUp,
    bool? submitting,
    double? latitude,
    double? longitude,
    bool setNullLocation = false, // útil para reset
  }) {
    return EmergencyReportState(
      protocolQuery: protocolQuery ?? this.protocolQuery,
      type: type ?? this.type,
      placeTime: placeTime ?? this.placeTime,
      description: description ?? this.description,
      isFollowUp: isFollowUp ?? this.isFollowUp,
      submitting: submitting ?? this.submitting,
      latitude: setNullLocation ? null : (latitude ?? this.latitude),
      longitude: setNullLocation ? null : (longitude ?? this.longitude),
    );
  }

  bool get isValid => type.isNotEmpty && placeTime.isNotEmpty && description.isNotEmpty;

  @override
  List<Object?> get props => [
    protocolQuery, type, placeTime, description, isFollowUp, submitting, latitude, longitude
  ];
}
