import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Future<void> add(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  Future<void> setDoc(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(collection).doc(id).set(data);
  }

  Future<void> setDocMerge(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(collection).doc(id).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getDoc(String collection, String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}
