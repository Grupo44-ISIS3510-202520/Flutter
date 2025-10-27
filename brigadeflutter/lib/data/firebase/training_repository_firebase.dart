import 'dart:async';
import '../entities/training_card.dart';
import '../entities/training_progress.dart';
import '../repositories/training_repository.dart';

/// Mock de FirebaseTrainingRepository para desarrollo local o pruebas sin conexión.
///
/// Se comporta igual que el repositorio real, pero devuelve datos simulados.
class FirebaseTrainingRepository implements TrainingRepository {
  final _cards = <TrainingCard>[
    const TrainingCard(
      id: 'basic',
      title: 'Basic First Aid',
      subtitle:
          'Learn the essentials of first aid, including CPR and basic wound care.',
      imageUrl:
          'https://m.media-amazon.com/images/I/71KY6V9LLOL._UF894,1000_QL80_.jpg',
      cta: 'Start Course',
    ),
    const TrainingCard(
      id: 'advanced',
      title: 'Advanced First Aid',
      subtitle:
          'Get certified in advanced first aid techniques and emergency response.',
      imageUrl:
          'https://www.shutterstock.com/image-vector/flat-vector-illustration-certified-first-260nw-2624013765.jpg',
      cta: 'Start Certification',
    ),
  ];

  var _progress = <TrainingProgress>[
    const TrainingProgress(label: 'First Aid Course', percent: 100),
    const TrainingProgress(label: 'Advanced Certification', percent: 40),
  ];

  @override
  Future<List<TrainingCard>> getCards() async {
    // Simula un pequeño delay de red
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _cards;
  }

  @override
  Future<List<TrainingProgress>> getProgress() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _progress;
  }

  @override
  Future<void> start(String cardId) async {
    // Simula una actualización de progreso
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _progress = _progress.map((p) {
      if (cardId == 'basic' && p.label.contains('First Aid')) {
        return p.copyWith(percent: (p.percent + 5).clamp(0, 100));
      }
      if (cardId == 'advanced' && p.label.contains('Advanced')) {
        return p.copyWith(percent: (p.percent + 5).clamp(0, 100));
      }
      return p;
    }).toList();
  }
}
