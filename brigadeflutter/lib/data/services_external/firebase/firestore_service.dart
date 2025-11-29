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
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return doc.data();
  }
  
  Future<List<Map<String, dynamic>>> queryCollection(
    String collection, {
    List<Map<String, dynamic>>? where,
    List<Map<String, dynamic>>? orderBy,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(collection);
    
    if (where != null) {
      for (final Map<String, dynamic> condition in where) {
        query = query.where(
          condition['field'] as String,
          isEqualTo: condition['op'] == '==' ? condition['value'] : null,
          isNotEqualTo: condition['op'] == '!=' ? condition['value'] : null,
          isLessThan: condition['op'] == '<' ? condition['value'] : null,
          isLessThanOrEqualTo: condition['op'] == '<=' ? condition['value'] : null,
          isGreaterThan: condition['op'] == '>' ? condition['value'] : null,
          isGreaterThanOrEqualTo: condition['op'] == '>=' ? condition['value'] : null,
        );
      }
    }
    
    if (orderBy != null) {
      for (final Map<String, dynamic> order in orderBy) {
        query = query.orderBy(
          order['field'] as String,
          descending: order['descending'] as bool? ?? false,
        );
      }
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data()).toList();
  }
}
