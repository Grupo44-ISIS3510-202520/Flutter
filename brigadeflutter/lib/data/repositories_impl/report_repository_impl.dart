import '../entities/report.dart';
import '../repositories/report_repository.dart';
import '../datasources/report_firestore_dao.dart';
import '../datasources/report_local_dao.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportFirestoreDao remote;
  final ReportLocalDao local;
  ReportRepositoryImpl({required this.remote, required this.local});

  @override
  Future<void> create(Report report) async {
    await remote.set(ReportModel.fromEntity(report));
  }

  @override
  Future<void> enqueue(Report report) => local.savePending(ReportModel.fromEntity(report));

  @override
  Future<List<Report>> pending() async =>
      (await local.listPending()).map((e) => e.toEntity()).toList();

  @override
  Future<void> markSent(Report report) => local.remove(report.id);
}