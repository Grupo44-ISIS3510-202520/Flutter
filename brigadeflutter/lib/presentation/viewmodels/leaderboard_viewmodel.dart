import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/cache/leaderboard_cache_manager.dart';

String _getWeekId() {
  final now = DateTime.now();
  final oneJan = DateTime(now.year, 1, 1);
  final days = now.difference(oneJan).inMilliseconds / 86400000;
  final week = ((days + oneJan.weekday + 1) / 7).ceil();
  return "${now.year}-W$week";
}

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
  final LeaderboardCacheManager _cacheManager = LeaderboardCacheManager();

  bool _loading = false;
  bool _loadedFromCache = false;
  String? _cachedWeekId;

  List<LeaderboardEntry> _entries = <LeaderboardEntry>[];

  bool get isLoading => _loading;
  bool get loadedFromCache => _loadedFromCache;
  List<LeaderboardEntry> get entries => _entries;
  String? get cachedWeekId => _cachedWeekId;

  Future<void> loadLeaderboard() async {
    _loading = true;
    _loadedFromCache = false;
    notifyListeners();

    // intentar cargar desde cache
    final cached = await _cacheManager.getCachedLeaderboard();
    if (cached != null) {
      _entries = (cached["entries"] as List<dynamic>).map((e) {
        return LeaderboardEntry(
          uid: e["uid"],
          email: e["email"],
          completedCount: e["completedCount"],
          lastCompletedAt: e["lastCompletedAt"] != null
              ? DateTime.parse(e["lastCompletedAt"])
              : null,
        );
      }).toList();

      _cachedWeekId = cached["weekId"];
      _loadedFromCache = true;
      notifyListeners();
    }

    // intentar Firestore
    try {
      final String weekId = _getWeekId();

      final doc = await _firestore
          .collection('weekly_leaderboard')
          .doc(weekId)
          .get();

      if (!doc.exists) {
        if (!_loadedFromCache) _entries = [];
        _loading = false;
        notifyListeners();
        return;
      }

      final data = doc.data()!;
      final rawEntries = data['entries'] as List<dynamic>? ?? [];

      final parsed = rawEntries.map((e) {
        return LeaderboardEntry(
          uid: e['uid'] as String,
          email: e['emailPrefix'] as String,
          completedCount: e['completedCount'] as int,
          lastCompletedAt: e['lastCompletedAt'] != null
              ? (e['lastCompletedAt'] as Timestamp).toDate()
              : null,
        );
      }).toList();

      _entries = parsed;
      _cachedWeekId = weekId;
      _loadedFromCache = false;

      // guardar en cache
      await _cacheManager.saveLeaderboard(parsed, weekId);

    } catch (_) {
      // si falla firestore, usa cache
    }

    _loading = false;
    notifyListeners();
  }
}
