import 'dart:async';

import 'package:flutter/foundation.dart';

import '../datasources/report_cache_dao.dart';
import '../datasources/report_firestore_dao.dart';
import '../datasources/report_local_dao.dart';
import '../entities/report.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';
import '../services_external/connectivity_service.dart';

// Top-level function for isolate execution
// Transforms list of ReportModel to Report entities in separate isolate
List<Report> _transformModelsToEntitiesIsolate(List<ReportModel> models) {
  return models.map((ReportModel m) => m.toEntity()).toList();
}

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
    // ISOLATE: Transform models in separate thread for better performance
    return compute(_transformModelsToEntitiesIsolate, models);
  }
  
  @override
  Future<({List<Report> reports, bool fromCache})> getUserReportsWithCache(String userId) async {
    // Check connectivity first
    final bool isOnline = await connectivity.isOnline();
    
    if (isOnline) {
      // MULTITHREADING STRATEGY 1: Parallel Operations
      // Run Firestore fetch and cache check concurrently to reduce total wait time
      List<ReportModel>? firestoreModels;
      Object? firestoreError;
      List<ReportModel>? cachedModels;
      
      // Execute both operations in parallel using Future.wait
      await Future.wait<void>([
        // Thread 1: Fetch from Firestore
        remoteDao.queryByUserId(userId).then((models) {
          firestoreModels = models;
        }).catchError((Object e) {
          firestoreError = e;
        }),
        // Thread 2: Check cache simultaneously (for instant fallback if Firestore fails)
        cacheDao.getCachedUserReports(userId).then((cached) {
          cachedModels = cached;
        }),
      ]);
      
      if (firestoreModels != null) {
        // MULTITHREADING STRATEGY 2: Isolate for CPU-intensive transformation
        // Use compute() to run transformation in separate isolate for true parallelism
        // This prevents blocking the main thread for large datasets
        final List<Report> reports = await compute(
          _transformModelsToEntitiesIsolate,
          firestoreModels!,
        );
        
        // MULTITHREADING STRATEGY 3: Fire-and-Forget Cache Write
        // Don't wait for cache write to complete - improves response time
        // The cache operation runs in background without blocking the return
        unawaited(cacheDao.cacheUserReports(userId, firestoreModels!));
        
        return (reports: reports, fromCache: false);
      } else {
        // Firestore failed - use cache (already fetched in parallel above)
        if (cachedModels != null && cachedModels!.isNotEmpty) {
          // ISOLATE: Transform cached models in separate thread
          final List<Report> reports = await compute(
            _transformModelsToEntitiesIsolate,
            cachedModels!,
          );
          return (reports: reports, fromCache: true);
        }
        // No cache available, rethrow Firestore error
        throw firestoreError ?? Exception('Failed to load reports');
      }
    } else {
      // Offline: try to use cache only
      final List<ReportModel>? cachedModels = await cacheDao.getCachedUserReports(userId);
      if (cachedModels != null && cachedModels.isNotEmpty) {
        // ISOLATE: Transform cached models in separate thread
        final List<Report> reports = await compute(
          _transformModelsToEntitiesIsolate,
          cachedModels,
        );
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
