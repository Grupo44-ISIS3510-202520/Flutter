import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/notification_model.dart';
import '../datasources/notification_dao.dart';
import '../entities/notification.dart';

class NotificationRepository {
  NotificationRepository({NotificationDao? dao})
      : _dao = dao;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationDao? _dao;

  Stream<List<NotificationModel>> getAlerts() {
    return _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => NotificationModel.fromFirestore(doc.data()))
            .toList());
  }

  /// Sync Firestore alerts to local database
  /// Call this once at app startup to populate the local DB
  Future<void> syncAlertsToLocal() async {
    try {
      if (_dao == null) {
        print(' [NotificationRepository] DAO is null, skipping sync');
        return;
      }

      print('🔄 [NotificationRepository] Starting Firestore → Local DB sync...');
      
      final snapshot = await _firestore
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .limit(100) // sync last 100 alerts
          .get();

      print('[NotificationRepository] Found ${snapshot.docs.length} alerts in Firestore');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final entity = NotificationEntity(
          id: doc.id,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          type: data['type'] ?? 'info',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: false,
        );

        await _dao.save(entity);
      }

      print('[NotificationRepository] Synced ${snapshot.docs.length} alerts to local DB');
    } catch (e) {
      print('[NotificationRepository] Sync failed: $e');
    }
  }

  /// Start listening to Firestore and auto-sync new alerts
  void startRealtimeSync() {
    if (_dao == null) {
      print('[NotificationRepository] DAO is null, skipping realtime sync');
      return;
    }

    print('[NotificationRepository] Starting realtime Firestore sync...');
    
    _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final entity = NotificationEntity(
            id: change.doc.id,
            title: data['title'] ?? '',
            message: data['message'] ?? '',
            type: data['type'] ?? 'info',
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            isRead: false,
          );

          await _dao.save(entity);
          print('[NotificationRepository] New alert saved to local DB: ${entity.title}');
        }
      }
    });
  }
}
