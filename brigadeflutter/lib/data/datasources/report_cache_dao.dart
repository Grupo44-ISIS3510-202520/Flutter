import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/report_model.dart';

/// Data Access Object for reports storage with hybrid strategy:
/// - flutter_cache_manager: Temporary cache with TTL (7 days) for quick access
/// - Hive: Persistent local storage for offline-first functionality
class ReportCacheDao {
  // Cache Manager (temporary, auto-expiring)
  static const String _cacheKey = 'reports_cache';
  static const Duration _maxAge = Duration(days: 7);
  static const int _maxNrOfCacheObjects = 100;
  
  // Hive (persistent local storage)
  static const String _hiveBoxName = 'reports_persistent_storage';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  late final CacheManager _cacheManager;
  late final Box<dynamic> _hiveBox;
  
  /// Initialize both cache manager and Hive persistent storage
  Future<void> init() async {
    final Directory directory = await getTemporaryDirectory();
    
    // Initialize flutter_cache_manager for temporary cache
    _cacheManager = CacheManager(
      Config(
        _cacheKey,
        stalePeriod: _maxAge,
        maxNrOfCacheObjects: _maxNrOfCacheObjects,
        repo: JsonCacheInfoRepository(databaseName: _cacheKey),
        fileService: HttpFileService(),
        fileSystem: IOFileSystem(directory.path),
      ),
    );
    
    // Initialize Hive for persistent local storage
    if (!Hive.isBoxOpen(_hiveBoxName)) {
      _hiveBox = await Hive.openBox(_hiveBoxName);
    } else {
      _hiveBox = Hive.box(_hiveBoxName);
    }
  }
  
  /// Save reports list to both cache and persistent storage
  /// HYBRID STRATEGY:
  /// 1. flutter_cache_manager: Fast access, auto-expires in 7 days
  /// 2. Hive: Persistent storage, never expires (offline-first)
  Future<void> cacheUserReports(String userId, List<ReportModel> reports) async {
    final String cacheKey = _getCacheKey(userId);
    final int now = DateTime.now().millisecondsSinceEpoch;
    
    final Map<String, dynamic> data = <String, dynamic>{
      'userId': userId,
      'reports': reports.map((ReportModel r) => r.toJson()).toList(),
      'cachedAt': now,
    };
    
    // STRATEGY 1: Save to flutter_cache_manager (temporary, fast)
    final String jsonString = jsonEncode(data);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
    
    await _cacheManager.putFile(
      cacheKey,
      bytes,
      maxAge: _maxAge,
      fileExtension: 'json',
    );
    
    // STRATEGY 2: Save to Hive (persistent, never expires)
    await _hiveBox.put('user_$userId', data);
    await _hiveBox.put(_lastSyncKey, now);
  }
  
  /// Retrieve cached reports for a specific user with hybrid strategy
  /// RETRIEVAL PRIORITY:
  /// 1. Try flutter_cache_manager first (fastest, if not expired)
  /// 2. Fallback to Hive persistent storage (always available)
  /// 3. Return null if both fail
  Future<List<ReportModel>?> getCachedUserReports(String userId) async {
    final String cacheKey = _getCacheKey(userId);
    
    // STRATEGY 1: Try cache manager first (fastest access)
    try {
      final FileInfo? fileInfo = await _cacheManager.getFileFromCache(cacheKey);
      
      if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
        // Cache hit and still valid
        final String jsonString = await fileInfo.file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
        
        final List<dynamic>? reportsList = data['reports'] as List<dynamic>?;
        if (reportsList != null) {
          return reportsList
              .map((dynamic json) => ReportModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      // Cache manager failed, continue to Hive fallback
    }
    
    // STRATEGY 2: Fallback to Hive persistent storage
    try {
      final dynamic hiveData = _hiveBox.get('user_$userId');
      
      if (hiveData == null) return null;
      
      final Map<dynamic, dynamic> dataMap = hiveData as Map<dynamic, dynamic>;
      final List<dynamic>? reportsList = dataMap['reports'] as List<dynamic>?;
      
      if (reportsList == null) return null;
      
      return reportsList
          .map((dynamic json) => ReportModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      return null;
    }
  }
  
  /// Check if cache exists for a user in either storage
  /// Returns true if data exists in cache manager OR Hive
  Future<bool> hasCachedReports(String userId) async {
    final String cacheKey = _getCacheKey(userId);
    
    // Check cache manager first
    final FileInfo? fileInfo = await _cacheManager.getFileFromCache(cacheKey);
    if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
      return true;
    }
    
    // Check Hive persistent storage
    return _hiveBox.containsKey('user_$userId');
  }
  
  /// Get when cache was last updated from Hive persistent storage
  Future<DateTime?> getLastSyncTime() async {
    try {
      final int? timestamp = _hiveBox.get(_lastSyncKey) as int?;
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }
  
  /// Clear all cached reports from both storages
  Future<void> clearCache() async {
    // Clear cache manager (temporary cache)
    await _cacheManager.emptyCache();
    
    // Clear Hive (persistent storage)
    await _hiveBox.clear();
  }
  
  /// Clear cache for a specific user from both storages
  Future<void> clearUserCache(String userId) async {
    final String cacheKey = _getCacheKey(userId);
    
    // Remove from cache manager
    await _cacheManager.removeFile(cacheKey);
    
    // Remove from Hive
    await _hiveBox.delete('user_$userId');
  }
  
  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    // This would require accessing internal cache manager stats
    // For now, return basic info
    return <String, dynamic>{
      'maxAge': _maxAge.inDays,
      'maxObjects': _maxNrOfCacheObjects,
    };
  }
  
  // Private helpers
  
  String _getCacheKey(String userId) => 'user_reports_$userId';
}
