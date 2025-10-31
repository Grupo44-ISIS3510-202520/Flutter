import '../entities/report.dart';

abstract class ReportRepository {
  Future<void> create(Report report);

  //sprint 3, strategies
  Future<void> enqueue(Report report);
  Future<List<Report>> pending();
  Future<void> markSent(Report report);

  // Future<void> createEmergencyReport({
  //   required String type,
  //   required String placeTime,
  //   required String description,
  //   required bool isFollowUp,
  //   double? latitude,
  //   double? longitude,
  //   bool isOnline = true,
  // });

  // Future<void> saveLocal(Report model);
  // Future<List<Report>> listPending();
  // Future<void> removeLocal(String id);
  // Future<void> syncPending();
}
