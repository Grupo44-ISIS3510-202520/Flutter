import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LeaderboardEntry {
  LeaderboardEntry({
    required this.uid,
    required this.email,
    required this.completedCount,
    this.lastCompletedAt,
  });
  final String uid;
  final String email;
  final int completedCount;
  final DateTime? lastCompletedAt;
}

class LeaderboardViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  DateTime? _lastUpdated;
  List<LeaderboardEntry> _entries = <LeaderboardEntry>[];

  bool get isLoading => _loading;
  List<LeaderboardEntry> get entries => _entries;

  Future<void> loadLeaderboard() async {
    if (_entries.isNotEmpty &&
        _lastUpdated != null &&
        DateTime.now().difference(_lastUpdated!).inDays < 7) {
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final QuerySnapshot<Map<String, dynamic>> usersSnapshot = await _firestore.collection('users').get();
      final QuerySnapshot<Map<String, dynamic>> trainingsSnapshot = await _firestore
          .collection('user_trainings')
          .get();

      final List<LeaderboardEntry> userTrainings = trainingsSnapshot.docs
          .where((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data().isNotEmpty)
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data = doc.data();
            int completedCount = 0;
            DateTime? lastCompletedAt;

            for (final MapEntry<String, dynamic> entry in data.entries) {
              if (entry.value is Map && entry.value['percent'] == 100) {
                completedCount++;
                final ts = entry.value['completedAt'];
                if (ts is Timestamp) {
                  final DateTime completedAt = ts.toDate();
                  if (lastCompletedAt == null ||
                      completedAt.isAfter(lastCompletedAt)) {
                    lastCompletedAt = completedAt;
                  }
                }
              }
            }

            final QueryDocumentSnapshot<Map<String, dynamic>> userDoc =
                usersSnapshot.docs.where((QueryDocumentSnapshot<Map<String, dynamic>> u) => u.id == doc.id).isNotEmpty
                ? usersSnapshot.docs.firstWhere((QueryDocumentSnapshot<Map<String, dynamic>> u) => u.id == doc.id)
                : usersSnapshot.docs.isNotEmpty
                ? usersSnapshot.docs.first
                : throw StateError('No users found');

            return LeaderboardEntry(
              uid: doc.id,
              email: (userDoc.data()['email'] as String?) ?? 'unknown',
              completedCount: completedCount,
              lastCompletedAt: lastCompletedAt,
            );
          })
          .where((LeaderboardEntry e) => e.completedCount > 0)
          .toList();

      userTrainings.sort((LeaderboardEntry a, LeaderboardEntry b) {
        if (b.completedCount != a.completedCount) {
          return b.completedCount.compareTo(a.completedCount);
        }
        if (a.lastCompletedAt != null && b.lastCompletedAt != null) {
          return a.lastCompletedAt!.compareTo(b.lastCompletedAt!);
        }
        return 0;
      });

      debugPrint('Found ${userTrainings.length} leaderboard entries');
      for (final LeaderboardEntry e in userTrainings) {
        debugPrint('${e.email} → ${e.completedCount} completados');
      }

      _entries = userTrainings.take(10).toList();
      _lastUpdated = DateTime.now();
    } catch (e, st) {
      debugPrint('Error loading leaderboard: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
