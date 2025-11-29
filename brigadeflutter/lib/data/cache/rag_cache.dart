// data/cache/rag_cache.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rag_model.dart';

class RagCache {
  static const String _cacheKey = 'rag_cache_map';
  static const int _maxCacheSize = 50;

  final SharedPreferences _prefs;
  Map<String, RagCacheEntry> _cache = {};

  RagCache(this._prefs);

  /// Initialize cache from persistent storage
  Future<void> init() async {
    await _loadFromPrefs();
    await cleanExpired();
  }

  /// Normalize query for consistent cache keys
  String _normalizeQuery(String query) {
    return query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Get cached entry for a query
  RagCacheEntry? get(String query) {
    final normalizedQuery = _normalizeQuery(query);
    final entry = _cache[normalizedQuery];

    if (entry != null && !entry.isExpired()) {
      return entry;
    }

    if (entry != null && entry.isExpired()) {
      _cache.remove(normalizedQuery);
      _saveToPrefs();
    }

    return null;
  }

  /// Store a new entry in cache
  Future<void> put(String query, String answer, List<String> sources) async {
    final normalizedQuery = _normalizeQuery(query);

    // Remove oldest entry if cache is full
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cache.entries
          .reduce((a, b) => a.value.timestamp < b.value.timestamp ? a : b)
          .key;
      _cache.remove(oldestKey);
    }

    _cache[normalizedQuery] = RagCacheEntry(
      query: query,
      answer: answer,
      sources: sources,
    );

    await _saveToPrefs();
  }

  /// Clear all cache
  Future<void> clear() async {
    _cache.clear();
    await _prefs.remove(_cacheKey);
  }

  /// Remove expired entries
  Future<void> cleanExpired() async {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired())
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      await _saveToPrefs();
    }
  }

  /// Get cache size
  int get size => _cache.length;

  /// Get all cache entries (sorted by timestamp, newest first)
  List<RagCacheEntry> getAllEntries() {
    return _cache.values
        .where((entry) => !entry.isExpired())
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Load cache from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        _cache = jsonMap.map(
              (key, value) => MapEntry(
            key,
            RagCacheEntry.fromJson(value as Map<String, dynamic>),
          ),
        );
      }
    } catch (e) {
      print('Error loading RAG cache: $e');
      _cache = {};
    }
  }

  /// Save cache to SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final jsonMap = _cache.map(
            (key, value) => MapEntry(key, value.toJson()),
      );
      final jsonString = json.encode(jsonMap);
      await _prefs.setString(_cacheKey, jsonString);
    } catch (e) {
      print('Error saving RAG cache: $e');
    }
  }
}