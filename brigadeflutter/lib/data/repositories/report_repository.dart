import '../entities/report.dart';
import '../models/report_model.dart';

abstract class ReportRepository {

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
  });

  Future<void> create(Report report);

  //sprint 3, strategies (no los implementé aún)
  Future<void> enqueue(Report report);
  Future<List<Report>> pending();
  Future<void> markSent(Report report);

  //new methods for local storage 
  Future<void> saveLocal(ReportModel model);
  Future<List<ReportModel>> listPending();
  Future<void> removeLocal(String reportId);
  Future<void> syncPending();
}