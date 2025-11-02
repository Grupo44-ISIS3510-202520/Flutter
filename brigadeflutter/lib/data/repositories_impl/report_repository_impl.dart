import '../entities/report.dart';
import '../repositories/report_repository.dart';
import '../datasources/report_firestore_dao.dart';
import '../datasources/report_local_dao.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportFirestoreDao remoteDao;
  final ReportLocalDao localDao;
  ReportRepositoryImpl({required this.remoteDao, required this.localDao});

  @override
  Future<void> create(Report report) async {
    await remoteDao.set(ReportModel.fromEntity(report));
  }

   @override
  Future<void> createEmergencyReport({
    required String type,
    required String placeTime,
    required String description,
    required bool isFollowUp,
    double? latitude,
    double? longitude,
    bool isOnline = true,
  }) async {
    final model = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toInt(),
      type: type,
      placeTime: placeTime,
      description: description,
      isFollowUp: isFollowUp,
      latitude: latitude,
      longitude: longitude,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    if (isOnline) {
      await remoteDao.set(model);
    } else {
      await localDao.savePending(model);
    }
  }

  @override
  Future<void> enqueue(Report report) => localDao.savePending(ReportModel.fromEntity(report));

  @override
  Future<List<Report>> pending() async =>
      (await localDao.listPending()).map((e) => e.toEntity()).toList();

  @override
  Future<void> markSent(Report report) => localDao.remove(report.id);

   @override
  Future<void> saveLocal(ReportModel model) async {
    await localDao.savePending(model);
  }

  @override
  Future<List<ReportModel>> listPending() async {
    return localDao.listPending();
  }

  @override
  Future<void> removeLocal(int id) async {
    await localDao.remove(id);
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
    final pending = await localDao.listPending();
    for (final report in pending) {
      await remoteDao.set(report);
      await localDao.remove(report.id.toInt());
    }
  }

  
}