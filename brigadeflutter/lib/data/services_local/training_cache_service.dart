import 'package:hive/hive.dart';
import '../../data/entities/training_card.dart';
import '../../data/entities/training_progress.dart';

class TrainingCacheService {
  final Box _box = Hive.box('trainingsBox');

  Future<void> saveTrainingData({
    required List<TrainingCard> cards,
    required List<TrainingProgress> progress,
  }) async {
    final cardsData = cards.map((c) => {
          'id': c.id,
          'title': c.title,
          'subtitle': c.subtitle,
          'imageUrl': c.imageUrl,
          'cta': c.cta,
        }).toList();

    final progressData = progress.map((p) => {
          'label': p.label,
          'percent': p.percent,
        }).toList();

    await _box.put('cards', cardsData);
    await _box.put('progress', progressData);
    await _box.put('lastUpdated', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? loadCachedData() {
    final cardsData = _box.get('cards');
    final progressData = _box.get('progress');
    if (cardsData == null || progressData == null) return null;

    return {
      'cards': List<Map<String, dynamic>>.from(cardsData),
      'progress': List<Map<String, dynamic>>.from(progressData),
      'lastUpdated': DateTime.tryParse(_box.get('lastUpdated') ?? ''),
    };
  }

  Future<void> clear() async => _box.clear();
}
