import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db;
  //FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  FirestoreService({FirebaseFirestore? db, bool enablePersistence = true})
      : _db = db ?? FirebaseFirestore.instance {
    if (enablePersistence) {
      try {
        // Para Flutter (Android/iOS) se establece en Settings
        _db.settings = const Settings(persistenceEnabled: true);
      } catch (e) {
        // En web o si ya está activada esto puede fallar; ignoramos el error
        // o loguear si lo necesitas.
      }
    }
  }

  Future<void> add(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  Future<void> setDoc(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).set(data);
  }

  Future<void> setDocMerge(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).set(data, SetOptions(merge: true));
  }
  Future<Map<String, dynamic>?> getDoc(String collection, String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}
