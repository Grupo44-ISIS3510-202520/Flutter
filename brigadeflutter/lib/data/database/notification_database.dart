import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../entities/notification.dart';

/// SQLite database for notifications
class NotificationDatabase {
  static final NotificationDatabase instance = NotificationDatabase._init();
  static Database? _database;

  NotificationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old table and recreate with new schema
      await db.execute('DROP TABLE IF EXISTS notifications');
      await _createDB(db, newVersion);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Index for faster queries
    await db.execute(
      'CREATE INDEX idx_timestamp ON notifications(timestamp DESC)',
    );
  }

  /// Insert a notification
  Future<void> insert(NotificationEntity notification) async {
    final db = await database;
    await db.insert(
      'notifications',
      _toMap(notification),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all notifications
  Future<List<NotificationEntity>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => _fromMap(map)).toList();
  }

  /// Get recent notifications (last N days)
  Future<List<NotificationEntity>> getRecent(int days) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'timestamp >= ?',
      whereArgs: [cutoff.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => _fromMap(map)).toList();
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE isRead = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Mark as read
  Future<void> markAsRead(String id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final db = await database;
    await db.update('notifications', {'isRead': 1});
  }

  /// Delete a notification
  Future<void> delete(String id) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('notifications');
  }

  /// Delete old notifications (older than retention days)
  Future<void> deleteOlderThan(int days) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days));

    await db.delete(
      'notifications',
      where: 'timestamp < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  /// Enforce max notification limit
  Future<void> enforceMaxLimit(int maxCount) async {
    final db = await database;

    // Get current count
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications',
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;

    if (count <= maxCount) return;

    // Delete oldest notifications
    final toDelete = count - maxCount;
    await db.rawDelete('''
      DELETE FROM notifications
      WHERE id IN (
        SELECT id FROM notifications
        ORDER BY timestamp ASC
        LIMIT ?
      )
    ''', [toDelete]);
  }

  /// Convert entity to map
  Map<String, dynamic> _toMap(NotificationEntity notification) {
    return {
      'id': notification.id,
      'title': notification.title,
      'message': notification.message,
      'type': notification.type,
      'timestamp': notification.timestamp.toIso8601String(),
      'isRead': notification.isRead ? 1 : 0,
    };
  }

  /// Convert map to entity
  NotificationEntity _fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] == 1,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
