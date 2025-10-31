import 'package:cloud_firestore/cloud_firestore.dart';

/// Mantiene el último ID usado en el documento `reports-counter/lastId` firestore.
class FirestoreIdGenerator {
  final FirebaseFirestore _db;
  FirestoreIdGenerator({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<int> nextReportId() async {
    final ref = _db.collection('reports-counter').doc('lastId');

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['value'] ?? 0) as int;
      final next = current + 1;
      tx.set(ref, {'value': next});
      return next;
    });
  }
}