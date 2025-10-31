import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTrainingRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserTrainingProgress() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('user_trainings').doc(uid).get();
    return doc.data();
  }

  Future<void> updateProgress(String trainingId, int newPercent) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('user_trainings').doc(uid);

    await docRef.set({
      trainingId: { 'percent': newPercent },
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (newPercent >= 100) {
      await _addMedalForCompletedTraining(trainingId);
    }
  }

  Future<void> _addMedalForCompletedTraining(String trainingId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = _firestore.collection('users').doc(uid);

    final snapshot = await userDoc.get();
    final data = snapshot.data() ?? {};
    final existingMedals = List<String>.from(data['medals'] ?? []);

    final medalName = _mapTrainingToMedal(trainingId);

    if (!existingMedals.contains(medalName)) {
      existingMedals.add(medalName);
      await userDoc.update({'medals': existingMedals});
    }
  }

  String _mapTrainingToMedal(String trainingId) {
    switch (trainingId) {
      case 'primeros_auxilios_basicos':
        return 'First Aid';
      case 'prevencion_incendios':
        return 'Fire Prevention';
      case 'evacuacion_emergencias':
        return 'Evacuation';
      case 'primeros_auxilios_psicologicos':
        return 'Psychological Aid';
      default:
        return trainingId;
    }
  }
}