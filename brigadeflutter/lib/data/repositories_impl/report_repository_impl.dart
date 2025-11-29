import '../datasources/report_firestore_dao.dart';
import '../datasources/report_local_dao.dart';
import '../entities/report.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({required this.remoteDao, required this.localDao});
  final ReportFirestoreDao remoteDao;
  final ReportLocalDao localDao;

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
}
