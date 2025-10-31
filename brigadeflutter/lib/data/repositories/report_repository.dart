import '../entities/report.dart';

abstract class ReportRepository {
  Future<void> create(Report report);

  //sprint 3, strategies
  Future<void> enqueue(Report report);
  Future<List<Report>> pending();
  Future<void> markSent(Report report);
}