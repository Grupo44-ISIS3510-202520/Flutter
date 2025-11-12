import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getAlerts() {
    return _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc.data()))
            .toList());
  }
}
