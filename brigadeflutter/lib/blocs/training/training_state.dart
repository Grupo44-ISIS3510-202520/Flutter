import 'package:equatable/equatable.dart';
import 'training_models.dart';

enum UiStatus { initial, loading, ready, error }

class TrainingState extends Equatable {
  final UiStatus status;
  final List<TrainingCard> cards;
  final List<TrainingProgress> progress;
  final bool submitting;

  const TrainingState({
    this.status = UiStatus.initial,
    this.cards = const [],
    this.progress = const [],
    this.submitting = false,
  });

  TrainingState copyWith({
    UiStatus? status,
    List<TrainingCard>? cards,
    List<TrainingProgress>? progress,
    bool? submitting,
  }) =>
      TrainingState(
        status: status ?? this.status,
        cards: cards ?? this.cards,
        progress: progress ?? this.progress,
        submitting: submitting ?? this.submitting,
      );

  @override
  List<Object?> get props => [status, cards, progress, submitting];
}

extension TrainingStateX on TrainingState {
  List<TrainingProgress> get pendingCertificates =>
      progress.where((p) => p.percent < 100).toList();

  List<TrainingProgress> get completedCertificates =>
      progress.where((p) => p.percent == 100).toList();
}
