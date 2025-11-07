import '../services_external/firebase/firestore_service.dart';
import '../models/report_model.dart';

// dao remoto (i/o crudo con firestore)
class ReportFirestoreDao {
  ReportFirestoreDao(this._fs);
  final FirestoreService _fs;

  // CREATE
  Future<void> set(ReportModel model) async {
    // usa id numérico como nombre del documento
    await _fs.setDoc('reports-emergency', model.id.toString(), model.toJson());
  }

  Future<void> setMerge(ReportModel model) async {
    await _fs.setDocMerge(
      'reports-emergency',
      model.id.toString(),
      model.toJson(),
    );
  }
}
