import '../datasources/report_cache_dao.dart';
import '../datasources/report_firestore_dao.dart';
import '../datasources/report_local_dao.dart';
import '../entities/report.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';
import '../services_external/connectivity_service.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({
    required this.remoteDao,
    required this.localDao,
    required this.cacheDao,
    required this.connectivity,
  });
  final ReportFirestoreDao remoteDao;
  final ReportLocalDao localDao;
  final ReportCacheDao cacheDao;
  final ConnectivityService connectivity;

  @override
  Future<void> create(Report report) async {
    await remoteDao.set(ReportModel.fromEntity(report));
  }

  @override
  Future<void> createEmergencyReport({
    required String type,
    required String place,
    required String description,
    required bool isFollowUp,
    required int elapsedTime,
    double? latitude,
    double? longitude,
    String? audioUrl,
    String? imageUrl,
    required int uiid,
    required String userId,
    bool isOnline = true,
  }) async {
    final now = DateTime.now();
    final ReportModel model = ReportModel(
      reportId: 'F${now.millisecondsSinceEpoch}',
      type: type,
      description: description,
      isFollowUp: isFollowUp,
      timestampMs: now.millisecondsSinceEpoch,
      elapsedTime: elapsedTime,
      place: place,
      latitude: latitude,
      longitude: longitude,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      uiid: uiid,
      userId: userId,
    );

    if (isOnline) {
      await remoteDao.set(model);
    } else {
      await localDao.savePending(model);
    }
  }

  @override
  Future<void> enqueue(Report report) =>
      localDao.savePending(ReportModel.fromEntity(report));

  @override
  Future<List<Report>> pending() async =>
      (await localDao.listPending()).map((ReportModel e) => e.toEntity()).toList();

  @override
  Future<void> markSent(Report report) => localDao.remove(report.reportId);

  @override
  Future<void> saveLocal(ReportModel model) async {
    await localDao.savePending(model);
  }

  @override
  Future<List<ReportModel>> listPending() async {
    return localDao.listPending();
  }

  @override
  Future<void> removeLocal(String reportId) async {
    await localDao.remove(reportId);
  }

  // @override
  // Future<void> syncPending() async {
  //   final pending = await localDao.listPending();
  //   for (final report in pending) {
  //     await remoteDao.set(report as ReportModel);
  //     await localDao.remove(report.id);
  //   }
  // }

  @override
  Future<void> syncPending() async {
    final List<ReportModel> pending = await localDao.listPending();
    for (final ReportModel report in pending) {
      await remoteDao.set(report);
      await localDao.remove(report.reportId);
    }
  }
  
  @override
  Future<List<Report>> getUserReports(String userId) async {
    final List<ReportModel> models = await remoteDao.queryByUserId(userId);
    return models.map((ReportModel m) => m.toEntity()).toList();
  }
  
  @override
  Future<({List<Report> reports, bool fromCache})> getUserReportsWithCache(String userId) async {
    // Check connectivity first
    final bool isOnline = await connectivity.isOnline();
    
    if (isOnline) {
      try {
        // Try to fetch from Firestore
        final List<ReportModel> models = await remoteDao.queryByUserId(userId);
        final List<Report> reports = models.map((ReportModel m) => m.toEntity()).toList();
        
        // Cache the successful fetch
        await cacheDao.cacheUserReports(userId, models);
        
        return (reports: reports, fromCache: false);
      } catch (e) {
        // Firestore failed, try cache fallback
        final List<ReportModel>? cachedModels = await cacheDao.getCachedUserReports(userId);
        if (cachedModels != null && cachedModels.isNotEmpty) {
          final List<Report> reports = cachedModels.map((ReportModel m) => m.toEntity()).toList();
          return (reports: reports, fromCache: true);
        }
        // No cache available, rethrow
        rethrow;
      }
    } else {
      // Offline: try to use cache
      final List<ReportModel>? cachedModels = await cacheDao.getCachedUserReports(userId);
      if (cachedModels != null && cachedModels.isNotEmpty) {
        final List<Report> reports = cachedModels.map((ReportModel m) => m.toEntity()).toList();
        return (reports: reports, fromCache: true);
      }
      
      // No cache and offline
      throw Exception('No internet connection and no cached reports available');
    }
  }
  
  @override
  Future<DateTime?> getLastCacheSyncTime() async {
    return cacheDao.getLastSyncTime();
  }
}
