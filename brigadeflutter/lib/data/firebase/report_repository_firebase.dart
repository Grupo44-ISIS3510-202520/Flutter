import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/report_repository.dart';

class FirebaseReportRepository implements ReportRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<void> createEmergencyReport({
    required String type,
    required String placeTime,
    required String description,
    required bool isFollowUp,
    String protocolQuery = '',
    double? latitude,
    double? longitude,
    String? userId,
    DateTime? createdAt,
  }) async {
    final uid = userId ?? _auth.currentUser?.uid;
    final now = createdAt ?? DateTime.now();

    await _db.collection('reports-emergency').add({
      'uid': uid,
      'type': type,
      'placeTime': placeTime,
      'description': description,
      'isFollowUp': isFollowUp,
      'protocolQuery': protocolQuery,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(now),
    });
  }
}
