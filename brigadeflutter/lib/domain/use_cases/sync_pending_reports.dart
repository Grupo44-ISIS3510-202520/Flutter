import '../../data/repositories/report_repository.dart';

class SyncPendingReports {
  final ReportRepository repo;
  SyncPendingReports(this.repo);

  Future<void> call() async {
    final items = await repo.pending();
    for (final r in items) {
      await repo.create(r);
    }
  }
}
