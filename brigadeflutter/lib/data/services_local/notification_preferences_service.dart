import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing notification preferences using SharedPreferences
class NotificationPreferencesService {
  // Keys for SharedPreferences
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyAutoMarkAsRead = 'notifications_auto_mark_read';
  static const String _keyShowBadge = 'notifications_show_badge';
  static const String _keySoundEnabled = 'notifications_sound_enabled';
  static const String _keyVibrationEnabled = 'notifications_vibration_enabled';
  static const String _keyLastViewedTimestamp = 'notifications_last_viewed';
  static const String _keyLastFilterUsed = 'notifications_last_filter';
  static const String _keyNotificationRetentionDays = 'notifications_retention_days';
  static const String _keyMaxNotifications = 'notifications_max_count';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyNotificationsEnabled) ?? true; // Default: enabled
  }

  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }


  /// Check if notifications should be auto-marked as read when viewed
  Future<bool> isAutoMarkAsReadEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyAutoMarkAsRead) ?? false; // Default: disabled
  }

  /// Enable or disable auto-mark-as-read
  Future<void> setAutoMarkAsRead(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyAutoMarkAsRead, enabled);
  }

  /// Check if notification badge should be shown
  Future<bool> shouldShowBadge() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyShowBadge) ?? true; // Default: show badge
  }

  /// Enable or disable notification badge
  Future<void> setShowBadge(bool show) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyShowBadge, show);
  }


  /// Check if notification sound is enabled
  Future<bool> isSoundEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keySoundEnabled) ?? true; // Default: enabled
  }

  /// Enable or disable notification sound
  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keySoundEnabled, enabled);
  }

  /// Check if vibration is enabled
  Future<bool> isVibrationEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyVibrationEnabled) ?? true; // Default: enabled
  }

  /// Enable or disable vibration
  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyVibrationEnabled, enabled);
  }

  // ==================== Last Viewed Timestamp ====================

  /// Get the timestamp when notifications were last viewed
  Future<DateTime?> getLastViewedTimestamp() async {
    final prefs = await _prefs;
    final timestamp = prefs.getString(_keyLastViewedTimestamp);
    return timestamp != null ? DateTime.tryParse(timestamp) : null;
  }

  /// Update the last viewed timestamp to now
  Future<void> updateLastViewedTimestamp() async {
    final prefs = await _prefs;
    await prefs.setString(
      _keyLastViewedTimestamp,
      DateTime.now().toIso8601String(),
    );
  }

  /// Check if there are new notifications since last viewed
  Future<bool> hasNewNotificationsSince(DateTime notificationTime) async {
    final lastViewed = await getLastViewedTimestamp();
    if (lastViewed == null) return true; // First time viewing
    return notificationTime.isAfter(lastViewed);
  }

 
  /// Get the last filter used in notification history
  Future<String?> getLastFilterUsed() async {
    final prefs = await _prefs;
    return prefs.getString(_keyLastFilterUsed);
  }

  /// Save the last filter used
  Future<void> setLastFilterUsed(String filter) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastFilterUsed, filter);
  }

 
  /// Get notification retention period in days
  Future<int> getRetentionDays() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyNotificationRetentionDays) ?? 30; // Default: 30 days
  }

  /// Set notification retention period in days
  Future<void> setRetentionDays(int days) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyNotificationRetentionDays, days);
  }

  /// Get maximum number of notifications to keep
  Future<int> getMaxNotifications() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyMaxNotifications) ?? 100; // Default: 100
  }

  /// Set maximum number of notifications to keep
  Future<void> setMaxNotifications(int max) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyMaxNotifications, max);
  }

  
  /// Reset all notification preferences to defaults
  Future<void> resetToDefaults() async {
    final prefs = await _prefs;
    await prefs.remove(_keyNotificationsEnabled);
    await prefs.remove(_keyAutoMarkAsRead);
    await prefs.remove(_keyShowBadge);
    await prefs.remove(_keySoundEnabled);
    await prefs.remove(_keyVibrationEnabled);
    await prefs.remove(_keyLastViewedTimestamp);
    await prefs.remove(_keyLastFilterUsed);
    await prefs.remove(_keyNotificationRetentionDays);
    await prefs.remove(_keyMaxNotifications);
  }


  /// Get all preferences as a map for debugging
  Future<Map<String, dynamic>> getAllPreferences() async {
    return {
      'enabled': await areNotificationsEnabled(),
      'autoMarkRead': await isAutoMarkAsReadEnabled(),
      'showBadge': await shouldShowBadge(),
      'sound': await isSoundEnabled(),
      'vibration': await isVibrationEnabled(),
      'lastViewed': (await getLastViewedTimestamp())?.toIso8601String(),
      'lastFilter': await getLastFilterUsed(),
      'retentionDays': await getRetentionDays(),
      'maxNotifications': await getMaxNotifications(),
    };
  }
}
