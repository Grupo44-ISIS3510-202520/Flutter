import '../../data/entities/report.dart';
import '../../data/repositories/report_repository.dart';

class GetUserReports {
  GetUserReports(this.repo);
  final ReportRepository repo;
  
  Future<List<Report>> call(String userId) async {
    return repo.getUserReports(userId);
  }
}
