import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTrainingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserTrainingProgress() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('user_trainings').doc(uid).get();
    return doc.data();
  }

  Future<void> updateProgress(String trainingId, int newPercent) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final DocumentReference<Map<String, dynamic>> docRef = _firestore.collection('user_trainings').doc(uid);

    await docRef.set(<String, dynamic>{
      trainingId: <String, int>{ 'percent': newPercent },
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (newPercent >= 100) {
      await _addMedalForCompletedTraining(trainingId);
    }
  }

  Future<void> _addMedalForCompletedTraining(String trainingId) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final DocumentReference<Map<String, dynamic>> userDoc = _firestore.collection('users').doc(uid);

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
    final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
    final List<String> existingMedals = List<String>.from(data['medals'] ?? <dynamic>[]);

    final String medalName = _mapTrainingToMedal(trainingId);

    if (!existingMedals.contains(medalName)) {
      existingMedals.add(medalName);
      await userDoc.update(<Object, Object?>{'medals': existingMedals});
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