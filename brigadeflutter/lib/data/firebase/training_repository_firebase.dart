import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/training_card.dart';
import '../entities/training_progress.dart';
import '../repositories/training_repository.dart';

class FirebaseTrainingRepository implements TrainingRepository {
  final _firestore = FirebaseFirestore.instance;

  final _cards = <TrainingCard>[
    const TrainingCard(
      id: 'primeros_auxilios_basicos',
      title: 'Primeros Auxilios Básicos',
      subtitle: 'Aprende los fundamentos esenciales de los primeros auxilios.',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/5562/5562032.png',
      cta: 'Comenzar curso',
    ),
    const TrainingCard(
      id: 'prevencion_incendios',
      title: 'Prevención y Control de Incendios',
      subtitle: 'Aprende cómo actuar ante incendios y cómo prevenirlos.',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/10760/10760660.png',
      cta: 'Iniciar curso',
    ),
    const TrainingCard(
      id: 'evacuacion_emergencias',
      title: 'Evacuación y Manejo de Emergencias',
      subtitle: 'Domina los protocolos de evacuación y manejo de crisis.',
      imageUrl: 'https://t4.ftcdn.net/jpg/11/12/70/29/360_F_1112702989_RxTVXkCaIQoRpkJLIcF5LX5fRXV1UOSZ.jpg',
      cta: 'Iniciar curso',
    ),
    const TrainingCard(
      id: 'primeros_auxilios_psicologicos',
      title: 'Primeros Auxilios Psicológicos',
      subtitle: 'Aprende a brindar apoyo emocional en situaciones críticas.',
      imageUrl: 'https://static.vecteezy.com/system/resources/thumbnails/035/015/479/small/mental-health-glyph-two-color-icon-design-free-vector.jpg',
      cta: 'Comenzar curso',
    ),
  ];

  @override
  Future<List<TrainingCard>> getCards() async {
    return _cards;
  }

  @override
  Future<List<TrainingProgress>> getProgress(String uid) async {
    final doc = await _firestore.collection('user_trainings').doc(uid).get();

    if (!doc.exists) {
      await _firestore.collection('user_trainings').doc(uid).set({
        for (final card in _cards) card.id: {'percent': 0}
      });

      return _cards
          .map((c) => TrainingProgress(id: c.id, label: c.title, percent: 0))
          .toList();
    }

    final data = doc.data() ?? {};

    return _cards.map((c) {
      final percent = (data[c.id]?['percent'] ?? 0) as int;
      return TrainingProgress(id: c.id, label: c.title, percent: percent);
    }).toList();
  }

  @override
Future<void> start(String uid, String cardId) async {
  final docRef = _firestore.collection('user_trainings').doc(uid);
  final snapshot = await docRef.get();

  int current = 0;
  if (snapshot.exists) {
    current = (snapshot.data()?[cardId]?['percent'] ?? 0) as int;
  }

  final newPercent = (current + 10).clamp(0, 100);
  final Map<String, dynamic> updateData = {
    cardId: {'percent': newPercent},
    'lastUpdated': FieldValue.serverTimestamp(),
  };

  if (newPercent >= 100) {
    updateData[cardId] = {
      'percent': newPercent,
      'completedAt': FieldValue.serverTimestamp(),
    };
  }

  await docRef.set(updateData, SetOptions(merge: true));

  if (newPercent >= 100) {
    await _addMedal(uid, cardId);
  }
}

  Future<void> _addMedal(String uid, String cardId) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();
    final data = snapshot.data() ?? {};
    final existing = List<String>.from(data['medals'] ?? []);

    final medal = _mapTrainingToMedal(cardId);

    if (!existing.contains(medal)) {
      existing.add(medal);
      await userDoc.update({'medals': existing});
    }
  }

  String _mapTrainingToMedal(String id) {
    switch (id) {
      case 'primeros_auxilios_basicos':
        return 'First Aid';
      case 'prevencion_incendios':
        return 'Fire Prevention';
      case 'evacuacion_emergencias':
        return 'Evacuation';
      case 'primeros_auxilios_psicologicos':
        return 'Psychological Aid';
      default:
        return id;
    }
  }
}