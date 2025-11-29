// data/repositories/rag_repository.dart

import '../models/rag_model.dart';

abstract class RagRepository {
  /// Initialize the cache
  Future<void> initializeCache();

  /// Get answer for a query
  /// Returns a tuple of (RagResponse, isFromCache)
  Future<(RagResponse, bool)> getAnswer(String query);

  /// Clear all cache
  Future<void> clearCache();

  /// Get cache size
  Future<int> getCacheSize();

  /// Get cache history
  Future<List<RagCacheEntry>> getCacheHistory();
}