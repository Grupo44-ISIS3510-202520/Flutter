// import 'package:cloud_firestore/cloud_firestore.dart';

// /// Mantiene el último ID usado en el documento `reports-counter/lastId` firestore.
// class FirestoreIdGenerator {
//   final FirebaseFirestore _db;
//   FirestoreIdGenerator({FirebaseFirestore? db})
//       : _db = db ?? FirebaseFirestore.instance;

//   Future<int> nextReportId() async {
//     final ref = _db.collection('reports-counter').doc('lastId');

//     return _db.runTransaction((tx) async {
//       final snap = await tx.get(ref);
//       final current = (snap.data()?['value'] ?? 0) as int;
//       final next = current + 1;
//       tx.set(ref, {'value': next});
//       return next;
//     });
//   }
// }

// ...existing code...
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreIdGenerator {
  FirestoreIdGenerator({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Future<int> nextReportId({
    int maxAttempts = 5,
    Duration timeoutPerAttempt = const Duration(seconds: 5),
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    final ref = _db.collection('reports-counter').doc('lastId');

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final next = await _db
            .runTransaction<int>((tx) async {
              final snap = await tx.get(ref);
              final current = (snap.data()?['value'] ?? 0) as int;
              final next = current + 1;
              tx.set(ref, {'value': next});
              return next;
            })
            .timeout(timeoutPerAttempt);
        return next;
      } on FirebaseException catch (e) {
        final transient = e.code == 'unavailable' || e.code == 'deadline-exceeded';
        if (!transient) rethrow;
        if (attempt >= maxAttempts - 1) rethrow;
        await Future.delayed(Duration(milliseconds: initialDelay.inMilliseconds * (1 << attempt)));
      } catch (_) {
        if (attempt >= maxAttempts - 1) rethrow;
        await Future.delayed(Duration(milliseconds: initialDelay.inMilliseconds * (1 << attempt)));
      }
    }

    throw Exception('Failed to obtain Firestore id after retries');
  }
}