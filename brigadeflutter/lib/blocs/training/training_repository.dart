import 'training_models.dart';

abstract class TrainingRepository {
  Future<List<TrainingCard>> getCards();
  Future<List<TrainingProgress>> getProgress();
  Future<void> start(String cardId);
}

class InMemoryTrainingRepository implements TrainingRepository {
  final _cards = <TrainingCard>[
    const TrainingCard(
      id: 'basic',
      title: 'Basic First Aid',
      subtitle: 'Learn the essentials of first aid, including CPR and basic wound care.',
      imageUrl: 'https://m.media-amazon.com/images/I/71KY6V9LLOL._UF894,1000_QL80_.jpg',
      cta: 'Start Course',
    ),
    const TrainingCard(
      id: 'advanced',
      title: 'Advanced First Aid',
      subtitle: 'Get certified in advanced first aid techniques and emergency response.',
      imageUrl: 'https://www.shutterstock.com/image-vector/flat-vector-illustration-certified-first-260nw-2624013765.jpg',
      cta: 'Start Certification',
    ),
  ];

  var _progress = <TrainingProgress>[
    const TrainingProgress(label: 'First Aid Course', percent: 100),
    const TrainingProgress(label: 'Advanced Certification', percent: 40),
  ];

  @override
  Future<List<TrainingCard>> getCards() async => _cards;

  @override
  Future<List<TrainingProgress>> getProgress() async => _progress;

  @override
  Future<void> start(String cardId) async {
    _progress = _progress.map((p) {
      if (cardId == 'basic' && p.label.contains('First Aid')) {
        return p.copyWith(percent: (p.percent + 5).clamp(0, 100));
      }
      if (cardId == 'advanced' && p.label.contains('Advanced')) {
        return p.copyWith(percent: (p.percent + 5).clamp(0, 100));
      }
      return p;
    }).toList();

    await Future<void>.delayed(const Duration(milliseconds: 150));
  }


}