import 'package:equatable/equatable.dart';

class EmergencyReportState extends Equatable {
  final String protocolQuery;
  final String type;
  final String placeTime;
  final String description;
  final bool isFollowUp;
  final bool submitting;

  const EmergencyReportState({
    this.protocolQuery = '',
    this.type = '',
    this.placeTime = '',
    this.description = '',
    this.isFollowUp = false,
    this.submitting = false,
  });

  bool get isValid => type.isNotEmpty && placeTime.isNotEmpty && description.isNotEmpty;

  EmergencyReportState copyWith({
    String? protocolQuery,
    String? type,
    String? placeTime,
    String? description,
    bool? isFollowUp,
    bool? submitting,
  }) {
    return EmergencyReportState(
      protocolQuery: protocolQuery ?? this.protocolQuery,
      type: type ?? this.type,
      placeTime: placeTime ?? this.placeTime,
      description: description ?? this.description,
      isFollowUp: isFollowUp ?? this.isFollowUp,
      submitting: submitting ?? this.submitting,
    );
  }

  @override
  List<Object?> get props => [protocolQuery, type, placeTime, description, isFollowUp, submitting];
}
