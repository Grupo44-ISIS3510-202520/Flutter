import 'package:hive/hive.dart';
import '../models/report_model.dart';

/// Data Access Object for reports cache using Hive
/// Handles local storage operations for offline report access
class ReportCacheDao {
  static const String _boxName = 'reports_cache';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }
  
  /// Save reports list to cache for a specific user
  Future<void> cacheUserReports(String userId, List<ReportModel> reports) async {
    final Box<dynamic> box = Hive.box(_boxName);
    final Map<String, dynamic> data = <String, dynamic>{
      'userId': userId,
      'reports': reports.map((ReportModel r) => r.toJson()).toList(),
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await box.put('user_$userId', data);
    await box.put(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Retrieve cached reports for a specific user
  Future<List<ReportModel>?> getCachedUserReports(String userId) async {
    final Box<dynamic> box = Hive.box(_boxName);
    final dynamic data = box.get('user_$userId');
    
    if (data == null) return null;
    
    final Map<dynamic, dynamic> dataMap = data as Map<dynamic, dynamic>;
    final List<dynamic>? reportsList = dataMap['reports'] as List<dynamic>?;
    if (reportsList == null) return null;
    
    return reportsList
        .map((dynamic json) => ReportModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
  
  /// Check if cache exists for a user
  Future<bool> hasCachedReports(String userId) async {
    final Box<dynamic> box = Hive.box(_boxName);
    return box.containsKey('user_$userId');
  }
  
  /// Get when cache was last updated
  Future<DateTime?> getLastSyncTime() async {
    final Box<dynamic> box = Hive.box(_boxName);
    final int? timestamp = box.get(_lastSyncKey) as int?;
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Clear all cached reports
  Future<void> clearCache() async {
    final Box<dynamic> box = Hive.box(_boxName);
    await box.clear();
  }
  
  /// Clear cache for a specific user
  Future<void> clearUserCache(String userId) async {
    final Box<dynamic> box = Hive.box(_boxName);
    await box.delete('user_$userId');
  }
}
