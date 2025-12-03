import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../presentation/viewmodels/leaderboard_viewmodel.dart';

class LeaderboardCacheManager {
  static const String _cacheKey = 'leaderboard_cache';

  final CacheManager _cacheManager;

  LeaderboardCacheManager({CacheManager? cacheManager})
      : _cacheManager = cacheManager ?? DefaultCacheManager();

  /// guardar leaderboard a cache
  Future<void> saveLeaderboard(List<LeaderboardEntry> entries, String weekId) async {
    final jsonData = {
      "weekId": weekId,
      "entries": entries
          .map((e) => {
                "uid": e.uid,
                "email": e.email,
                "completedCount": e.completedCount,
                "lastCompletedAt": e.lastCompletedAt?.toIso8601String(),
              })
          .toList(),
    };

    final jsonString = jsonEncode(jsonData);

    await _cacheManager.putFile(
      _cacheKey,
      utf8.encode(jsonString),
      maxAge: const Duration(days: 7), // recargar cada 7 dias
    );
  }

  /// Load leaderboard from cache
  Future<Map<String, dynamic>?> getCachedLeaderboard() async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(_cacheKey);
      if (fileInfo == null) return null;

      final jsonString = await fileInfo.file.readAsString();
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    await _cacheManager.removeFile(_cacheKey);
  }
}
