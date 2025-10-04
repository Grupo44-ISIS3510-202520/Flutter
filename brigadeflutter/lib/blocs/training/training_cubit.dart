import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'training_repository.dart';
import 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final TrainingRepository repo;
  TrainingCubit(this.repo) : super(const TrainingState());

  Future<void> load() async {
    emit(state.copyWith(status: UiStatus.loading));
    try {
      final cards = await repo.getCards();
      final prog = await repo.getProgress();

      final pending = prog.where((p) => p.percent < 100).toList();
      if (pending.isNotEmpty) {
        await FirebaseAnalytics.instance.logEvent(
          name: 'certificate_pending_viewed',
          parameters: {
            'pending_count': pending.length,
            'pending_labels': pending.map((p) => p.label).join(", "),
          },
        );
      }

      emit(state.copyWith(status: UiStatus.ready, cards: cards, progress: prog));
    } catch (e, st) {
      print(" Error en TrainingCubit.load(): $e");
      print(st); 
      emit(state.copyWith(status: UiStatus.error));
    }

  }

  Future<void> onCtaPressed(String cardId) async {
    emit(state.copyWith(submitting: true));
    await repo.start(cardId);
    final prog = await repo.getProgress();

    for (final p in prog) {
      if (p.percent == 100) {
        await FirebaseAnalytics.instance.logEvent(
          name: 'certificate_completed',
          parameters: {
            'certificate_id': cardId,
            'certificate_label': p.label,
          },
        );
      }
    }

    emit(state.copyWith(submitting: false, progress: prog));
  }
}
