import 'package:equatable/equatable.dart';

class TrainingProgress extends Equatable {
  // 0..100

  const TrainingProgress({
    required this.id,
    required this.label,
    required this.percent,
  });
  final String id;
  final String label;
  final int percent;

  TrainingProgress copyWith({String? id, String? label, int? percent}) {
    return TrainingProgress(
      id: id ?? this.id,
      label: label ?? this.label,
      percent: percent ?? this.percent,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, label, percent];
}
