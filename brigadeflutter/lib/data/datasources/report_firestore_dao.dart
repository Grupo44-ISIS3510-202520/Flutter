import '../models/report_model.dart';
import '../services_external/firebase/firestore_service.dart';

// dao remoto (i/o crudo con firestore)
class ReportFirestoreDao {
  ReportFirestoreDao(this._fs);
  final FirestoreService _fs;

  // CREATE
  Future<void> set(ReportModel model) async {
    // usa reportId String como nombre del documento (F## o K##)
    await _fs.setDoc('reports', model.reportId, model.toJson());
  }

  Future<void> setMerge(ReportModel model) async {
    await _fs.setDocMerge('reports-emergency', model.reportId, model.toJson());
  }

  // Query reports by userId
  Future<List<ReportModel>> queryByUserId(String userId) async {
    final List<Map<String, dynamic>> docs = await _fs.queryCollection(
      'reports',
      where: [
        {'field': 'userId', 'op': '==', 'value': userId},
      ],
      orderBy: [
        {'field': 'timestamp', 'descending': true},
      ],
    );
    return docs
        .map((Map<String, dynamic> doc) => ReportModel.fromJson(doc))
        .toList();
  }
}
