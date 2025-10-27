import 'package:equatable/equatable.dart';

class TrainingProgress extends Equatable {
  final String label;
  final int percent; // 0..100

  const TrainingProgress({
    required this.label,
    required this.percent,
  });

  TrainingProgress copyWith({String? label, int? percent}) {
    return TrainingProgress(
      label: label ?? this.label,
      percent: percent ?? this.percent,
    );
  }

  @override
  List<Object?> get props => [label, percent];
}
