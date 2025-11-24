import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/notification_dao.dart';
import '../../data/entities/notification.dart';
import '../../data/services_local/notification_preferences_service.dart';

/// Simple MVVM ViewModel for Notifications
class SimpleNotificationViewModel extends ChangeNotifier {
  SimpleNotificationViewModel({
    required NotificationDao dao,
    required NotificationPreferencesService preferences,
  })  : _dao = dao,
        _preferences = preferences {
    // Start listening to real-time database changes
    _notificationSubscription = _dao.notificationsStream.listen((notifications) {
      print('[NotificationVM] Received ${notifications.length} notifications from stream');
      _notifications = notifications;
      _unreadCount = notifications.where((n) => !n.isRead).length;
      notifyListeners();
    });
  }

  final NotificationDao _dao;
  final NotificationPreferencesService _preferences;
  StreamSubscription<List<NotificationEntity>>? _notificationSubscription;

  // State
  List<NotificationEntity> _notifications = [];
  bool _loading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _loading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  /// Initialize - load preferences
  Future<void> init() async {
    await _loadPreferences();
  }

  /// Load all notifications
  Future<void> loadNotifications() async {
    _setLoading(true);

    try {
      print('[NotificationVM] Starting to load notifications...');
      _notifications = await _dao.getAll();
      print('[NotificationVM] Loaded ${_notifications.length} notifications from DAO');
      _unreadCount = await _dao.getUnreadCount();
      print('[NotificationVM] Unread count: $_unreadCount');
      await _preferences.updateLastViewedTimestamp();

      // Auto-mark as read if enabled
      if (await _preferences.isAutoMarkAsReadEnabled()) {
        print('[NotificationVM] Auto-mark as read is enabled, marking all as read...');
        await markAllAsRead();
      }
      
      // Debug: print first notification if any
      if (_notifications.isNotEmpty) {
        final first = _notifications.first;
        print('[NotificationVM] First notification: title="${first.title}", message="${first.message}", type="${first.type}", timestamp=${first.timestamp}');
      }
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      print('[NotificationVM] Error loading notifications: $e');
    } finally {
      _setLoading(false);
      print(' [NotificationVM] Loading complete. Final count: ${_notifications.length}');
    }
  }

  /// Load recent notifications
  Future<void> loadRecent({int days = 7}) async {
    _setLoading(true);

    try {
      _notifications = await _dao.getRecent(days);
      _unreadCount = await _dao.getUnreadCount();
    } catch (e) {
      _error = 'Failed to load recent notifications: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Filter unread
  void filterUnread() {
    _notifications = _notifications.where((n) => !n.isRead).toList();
    notifyListeners();
  }

  /// Mark as read
  Future<void> markAsRead(String id) async {
    try {
      await _dao.markAsRead(id);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark as read: $e';
      notifyListeners();
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _dao.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark all as read: $e';
      notifyListeners();
    }
  }

  /// Delete notification
  Future<void> delete(String id) async {
    try {
      await _dao.delete(id);

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        if (!_notifications[index].isRead) {
          _unreadCount = (_unreadCount - 1).clamp(0, 999);
        }
        _notifications.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to delete: $e';
      notifyListeners();
    }
  }

  /// Clear all
  Future<void> clearAll() async {
    try {
      await _dao.clearAll();
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear all: $e';
      notifyListeners();
    }
  }

  /// Cleanup old notifications
  Future<void> cleanup() async {
    try {
      final retentionDays = await _preferences.getRetentionDays();
      final maxCount = await _preferences.getMaxNotifications();
      await _dao.cleanup(retentionDays, maxCount);
    } catch (e) {
      _error = 'Cleanup failed: $e';
    }
  }

  /// Get cache info (for debugging)
  Future<Map<String, dynamic>> getCacheInfo() async {
    final info = await _dao.getCacheInfo();
    print('[NotificationVM] Cache info: $info');
    return info;
  }

  /// Private helper to set loading state
  void _setLoading(bool value) {
    _loading = value;
    _error = null;
    notifyListeners();
  }

  /// Private helper to load preferences
  Future<void> _loadPreferences() async {
    // Preferences loaded in preferences service
    notifyListeners();
  }
  
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
