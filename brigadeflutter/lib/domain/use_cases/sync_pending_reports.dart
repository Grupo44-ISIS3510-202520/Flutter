import '../../data/repositories/report_repository.dart';

class SyncPendingReports {
  SyncPendingReports(this.repo);
  final ReportRepository repo;

  Future<void> call() async {
    final items = await repo.pending();
    for (final r in items) {
      await repo.create(r);
    }
  }
}
