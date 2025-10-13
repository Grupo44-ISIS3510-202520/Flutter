import 'package:brigadeappv2/domain/emergency_report/emergency_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class EmergencyReportRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  // Define the method to submit an emergency report
  Future<void> createEmergencyReport(EmergencyReport emergencyReport) async {
    final uid = emergencyReport.userId ?? _auth.currentUser?.uid;
    final now = emergencyReport.createdAt ?? DateTime.now();


    await _db.collection('reports-emergency').add({
      'uid':uid,
      'type': emergencyReport.type,
      'placeTime': emergencyReport.place,
      'description': emergencyReport.description,
      'isFollowUp': emergencyReport.isFollowUp,
      'latitude': emergencyReport.latitude,
      'longitude': emergencyReport.longitude,
      'createdAt': Timestamp.fromDate(now),
    });
  }
}
