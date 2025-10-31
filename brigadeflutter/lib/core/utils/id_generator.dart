import 'package:cloud_firestore/cloud_firestore.dart';

/// Mantiene el último ID usado en el documento `reports-counter/lastId` firestore.
class FirestoreIdGenerator {
  final FirebaseFirestore _db;
  FirestoreIdGenerator({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ...existing code...
    Future<int> nextReportId({int maxAttempts = 5, Duration timeoutPerAttempt = const Duration(seconds: 5), Duration initialDelay = const Duration(seconds: 1)}) async {
      final ref = _db.collection('reports-counter').doc('lastId');
  
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          // runTransaction puede resolverse lento; aplicamos timeout por intento.
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
          // Retries solo para errores transitorios típicos
          final transient = e.code == 'unavailable' || e.code == 'deadline-exceeded' || e.message?.contains('transient') == true;
          if (!transient) rethrow;
  
          if (attempt >= maxAttempts - 1) {
            // agotados los reintentos
            rethrow;
          }
          // backoff exponencial
          final waitMs = initialDelay.inMilliseconds * (1 << attempt);
          await Future.delayed(Duration(milliseconds: waitMs));
          continue;
        } catch (e) {
          // para cualquier otro error, también reintentamos un par de veces
          if (attempt >= maxAttempts - 1) rethrow;
          final waitMs = initialDelay.inMilliseconds * (1 << attempt);
          await Future.delayed(Duration(milliseconds: waitMs));
        }
      }
  
      throw Exception('Firestore unavailable after $maxAttempts attempts');
    }
  }