import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

String _getWeekId() {
  final now = DateTime.now();
  final firstDayOfYear = DateTime(now.year, 1, 1);
  final diff = now.difference(firstDayOfYear);
  final week = ((diff.inDays + firstDayOfYear.weekday) / 7).ceil();
  return "${now.year}-W$week";
}
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
  _loading = true;
  notifyListeners();

  try {
    
    final String weekId = _getWeekId();

    final doc = await _firestore
      .collection('weekly_leaderboard')
      .doc(weekId)
      .get();


    if (!doc.exists) {
      debugPrint("No leaderboard found");
      _entries = [];
      return;
    }

    final data = doc.data()!;
    final List<dynamic> rawEntries = data['entries'] ?? [];

    final List<LeaderboardEntry> parsed = rawEntries.map((dynamic e) {
      return LeaderboardEntry(
        uid: e['uid'] as String,
        email: e['emailPrefix'] as String,
        completedCount: e['completedCount'] as int,
        lastCompletedAt: e['lastCompletedAt'] == null
            ? null
            : (e['lastCompletedAt'] as Timestamp).toDate(),
      );
    }).toList();

    _entries = parsed;
  } finally {
    _loading = false;
    notifyListeners();
  }
}

}
