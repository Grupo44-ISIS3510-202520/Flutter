import '../../data/entities/report.dart';
import '../../data/repositories/report_repository.dart';

/// Use case for getting user reports with cache-fallback strategy
/// Implements the business logic for offline support:
/// - Online: fetch from Firestore, cache result
/// - Offline or Firestore error: fallback to cached data if available
class GetUserReportsWithCache {
  GetUserReportsWithCache(this.repo);
  final ReportRepository repo;
  
  /// Get reports for a user with cache fallback strategy
  /// Returns a record with:
  /// - reports: List of Report entities
  /// - fromCache: true if data came from cache, false if from Firestore
  Future<({List<Report> reports, bool fromCache})> call(String userId) async {
    return repo.getUserReportsWithCache(userId);
  }
  
  /// Get when cache was last synced
  Future<DateTime?> getLastSyncTime() async {
    return repo.getLastCacheSyncTime();
  }
}
