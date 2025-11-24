import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../entities/notification.dart';

/// Notification cache using flutter_cache_manager
class NotificationCacheManager {
  static const String _cacheKey = 'notifications_cache';
  static const String _unreadCountKey = 'unread_count_cache';

  final CacheManager _cacheManager;

  NotificationCacheManager({CacheManager? cacheManager})
      : _cacheManager = cacheManager ?? DefaultCacheManager();

  /// Save notifications to cache
  Future<void> saveNotifications(List<NotificationEntity> notifications) async {
    final jsonData = notifications.map((n) => _toJson(n)).toList();
    final jsonString = jsonEncode(jsonData);

    await _cacheManager.putFile(
      _cacheKey,
      utf8.encode(jsonString),
      maxAge: const Duration(hours: 24),
    );
  }

  /// Get cached notifications
  Future<List<NotificationEntity>?> getCachedNotifications() async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(_cacheKey);
      if (fileInfo == null) return null;

      final jsonString = await fileInfo.file.readAsString();
      final List<dynamic> jsonData = jsonDecode(jsonString);

      return jsonData.map((json) => _fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Save unread count to cache
  Future<void> saveUnreadCount(int count) async {
    await _cacheManager.putFile(
      _unreadCountKey,
      utf8.encode(count.toString()),
      maxAge: const Duration(hours: 24),
    );
  }

  /// Get cached unread count
  Future<int?> getCachedUnreadCount() async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(_unreadCountKey);
      if (fileInfo == null) return null;

      final countString = await fileInfo.file.readAsString();
      return int.tryParse(countString);
    } catch (e) {
      return null;
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await _cacheManager.removeFile(_cacheKey);
    await _cacheManager.removeFile(_unreadCountKey);
  }

  /// Convert entity to JSON
  Map<String, dynamic> _toJson(NotificationEntity notification) {
    return {
      'id': notification.id,
      'title': notification.title,
      'message': notification.message,
      'type': notification.type,
      'timestamp': notification.timestamp.toIso8601String(),
      'isRead': notification.isRead,
    };
  }

  /// Convert JSON to entity
  NotificationEntity _fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
    );
  }
}
