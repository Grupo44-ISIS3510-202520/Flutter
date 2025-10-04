import 'package:flutter_bloc/flutter_bloc.dart';
import 'training_repository.dart';
import 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final TrainingRepository repo;
  TrainingCubit(this.repo) : super(const TrainingState());

  Future<void> load() async {
    emit(state.copyWith(status: UiStatus.loading));
    try {
      final cards = await repo.getCards();
      final prog  = await repo.getProgress();
      emit(state.copyWith(status: UiStatus.ready, cards: cards, progress: prog));
    } catch (_) {
      emit(state.copyWith(status: UiStatus.error));
    }
  }

  Future<void> onCtaPressed(String cardId) async {
    emit(state.copyWith(submitting: true));
    await repo.start(cardId);
    final prog = await repo.getProgress();
    emit(state.copyWith(submitting: false, progress: prog));
  }
}