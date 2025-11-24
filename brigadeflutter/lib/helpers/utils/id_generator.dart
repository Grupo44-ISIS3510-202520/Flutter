import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreIdGenerator {
  FirestoreIdGenerator({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Future<int> nextReportId({
    int maxAttempts = 5,
    Duration timeoutPerAttempt = const Duration(seconds: 5),
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    final DocumentReference<Map<String, dynamic>> ref = _db.collection('reports-counter').doc('lastId');

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final int next = await _db
            .runTransaction<int>((Transaction tx) async {
              final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(ref);
              final int current = (snap.data()?['value'] ?? 0) as int;
              final int next = current + 1;
              tx.set(ref, <String, int>{'value': next});
              return next;
            })
            .timeout(timeoutPerAttempt);
        return next;
      } on FirebaseException catch (e) {
        final bool transient = e.code == 'unavailable' || e.code == 'deadline-exceeded';
        if (!transient) {
          rethrow;
        }
        if (attempt >= maxAttempts - 1) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: initialDelay.inMilliseconds * (1 << attempt)));
      } catch (_) {
        if (attempt >= maxAttempts - 1) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: initialDelay.inMilliseconds * (1 << attempt)));
      }
    }

    throw Exception('Failed to obtain Firestore id after retries');
  }
}