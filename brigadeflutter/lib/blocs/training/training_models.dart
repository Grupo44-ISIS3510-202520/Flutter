import 'package:equatable/equatable.dart';

class TrainingCard extends Equatable {
  final String id, title, subtitle, imageUrl, cta;
  const TrainingCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.cta,
  });
  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, cta];
}

class TrainingProgress extends Equatable {
  final String label;
  final int percent; // 0..100
  const TrainingProgress({required this.label, required this.percent});
  TrainingProgress copyWith({String? label, int? percent}) =>
      TrainingProgress(label: label ?? this.label, percent: percent ?? this.percent);
  @override
  List<Object?> get props => [label, percent];
}