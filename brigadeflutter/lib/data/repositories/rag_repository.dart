import '../models/rag_model.dart';

abstract class RagRepository {

  Future<void> initializeCache();

  Future<(RagResponse, bool)> getAnswer(String query);

  Future<void> clearCache();

  Future<int> getCacheSize();

  Future<void> warmUp();

  Future<List<RagCacheEntry>> getCacheHistory();
}