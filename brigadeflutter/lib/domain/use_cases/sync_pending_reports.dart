import '../../data/entities/report.dart';
import '../../data/repositories/report_repository.dart';

class SyncPendingReports {
  SyncPendingReports(this.repo);
  final ReportRepository repo;

  Future<void> call() async {
    final List<Report> items = await repo.pending();
    for (final Report r in items) {
      await repo.create(r);
    }
  }
}
