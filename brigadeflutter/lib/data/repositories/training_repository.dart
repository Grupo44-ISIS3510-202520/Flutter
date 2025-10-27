import '../entities/training_card.dart';
import '../entities/training_progress.dart';

abstract class TrainingRepository {
  Future<List<TrainingCard>> getCards();
  Future<List<TrainingProgress>> getProgress();
  Future<void> start(String cardId);
}
