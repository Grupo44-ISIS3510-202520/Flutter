import 'dart:async';
import '../cache/notification_cache_manager.dart';
import '../database/notification_database.dart';
import '../entities/notification.dart';

/// Simple DAO for notifications
/// Uses SQLite for persistence + flutter_cache_manager for caching
class NotificationDao {
  NotificationDao({
    NotificationDatabase? database,
    NotificationCacheManager? cache,
  })  : _db = database ?? NotificationDatabase.instance,
        _cache = cache ?? NotificationCacheManager();

  final NotificationDatabase _db;
  final NotificationCacheManager _cache;
  
  // Stream controller to notify when notifications change
  final _notificationsController = StreamController<List<NotificationEntity>>.broadcast();
  
  /// Stream of notifications that updates whenever data changes
  Stream<List<NotificationEntity>> get notificationsStream => _notificationsController.stream;

  /// Save notification (to DB and cache)
  Future<void> save(NotificationEntity notification) async {
    await _db.insert(notification);
    await _clearCache(); // Invalidate cache
    _emitLatestNotifications(); // Notify listeners
  }

  /// Get all notifications (from cache first, then DB)
  Future<List<NotificationEntity>> getAll() async {
    // Try cache first
    final cached = await _cache.getCachedNotifications();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // Fallback to database
    final notifications = await _db.getAll();

    // Save to cache
    await _cache.saveNotifications(notifications);

    return notifications;
  }

  /// Get recent notifications
  Future<List<NotificationEntity>> getRecent(int days) async {
    final notifications = await _db.getRecent(days);

    // Update cache with recent notifications
    await _cache.saveNotifications(notifications);

    return notifications;
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    // Try cache first
    final cached = await _cache.getCachedUnreadCount();
    if (cached != null) return cached;

    // Get from database
    final count = await _db.getUnreadCount();

    // Save to cache
    await _cache.saveUnreadCount(count);

    return count;
  }

  /// Mark as read
  Future<void> markAsRead(String id) async {
    await _db.markAsRead(id);
    await _clearCache(); // Invalidate cache
    _emitLatestNotifications(); // Notify listeners
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await _db.markAllAsRead();
    await _clearCache(); // Invalidate cache
    _emitLatestNotifications(); // Notify listeners
  }

  /// Delete notification
  Future<void> delete(String id) async {
    await _db.delete(id);
    await _clearCache(); // Invalidate cache
    _emitLatestNotifications(); // Notify listeners
  }

  /// Clear all
  Future<void> clearAll() async {
    await _db.clearAll();
    await _clearCache();
  }

  /// Cleanup old notifications
  Future<void> cleanup(int retentionDays, int maxCount) async {
    await _db.deleteOlderThan(retentionDays);
    await _db.enforceMaxLimit(maxCount);
    await _clearCache(); // Invalidate cache
  }

  /// Clear cache (invalidate)
  Future<void> _clearCache() async {
    await _cache.clearCache();
  }

  /// Get cache info (for debugging)
  Future<Map<String, dynamic>> getCacheInfo() async {
    final cached = await _cache.getCachedNotifications();
    final cachedCount = await _cache.getCachedUnreadCount();

    return {
      'hasCachedNotifications': cached != null,
      'cachedCount': cached?.length ?? 0,
      'cachedUnreadCount': cachedCount,
    };
  }
  
  /// Emit latest notifications to stream listeners
  void _emitLatestNotifications() async {
    try {
      final notifications = await _db.getAll();
      _notificationsController.add(notifications);
    } catch (e) {
      print('[NotificationDao] Error emitting notifications: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _notificationsController.close();
  }
}
