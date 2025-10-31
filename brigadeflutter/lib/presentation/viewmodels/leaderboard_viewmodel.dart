import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LeaderboardEntry {
  final String uid;
  final String email;
  final int completedCount;
  final DateTime? lastCompletedAt;

  LeaderboardEntry({
    required this.uid,
    required this.email,
    required this.completedCount,
    this.lastCompletedAt,
  });
}

class LeaderboardViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  DateTime? _lastUpdated;
  List<LeaderboardEntry> _entries = [];

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
      final usersSnapshot = await _firestore.collection('users').get();
      final trainingsSnapshot = await _firestore.collection('user_trainings').get();

      final userTrainings = trainingsSnapshot.docs
          .where((doc) => doc.data().isNotEmpty)
          .map((doc) {
        final data = doc.data();
        int completedCount = 0;
        DateTime? lastCompletedAt;

        for (final entry in data.entries) {
          if (entry.value is Map &&
              entry.value['percent'] == 100) {
            completedCount++;
            final ts = entry.value['completedAt'];
            if (ts is Timestamp) {
              final completedAt = ts.toDate();
              if (lastCompletedAt == null ||
                  completedAt.isAfter(lastCompletedAt)) {
                lastCompletedAt = completedAt;
              }
            }
          }
        }

        final userDoc = usersSnapshot.docs.firstWhere(
          (u) => u.id == doc.id,
          orElse: () => usersSnapshot.docs.isNotEmpty
              ? usersSnapshot.docs.first
              : throw StateError('No users found'),
        );

        return LeaderboardEntry(
          uid: doc.id,
          email: (userDoc.data()['email'] as String?) ?? 'unknown',
          completedCount: completedCount,
          lastCompletedAt: lastCompletedAt,
        );
      }).where((e) => e.completedCount > 0).toList();

      userTrainings.sort((a, b) {
        if (b.completedCount != a.completedCount) {
          return b.completedCount.compareTo(a.completedCount);
        }
        if (a.lastCompletedAt != null && b.lastCompletedAt != null) {
          return a.lastCompletedAt!.compareTo(b.lastCompletedAt!);
        }
        return 0;
      });

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