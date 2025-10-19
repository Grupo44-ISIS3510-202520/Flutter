import '../../services_external/firebase/firestore_service.dart';
import '../../domain/models/report_model.dart';

// dao remoto (i/o crudo con firestore)
class ReportFirestoreDao {
  final FirestoreService _fs;
  ReportFirestoreDao(this._fs);

  Future<void> set(ReportModel model) async {
    // usa id numérico como nombre del documento
    await _fs.setDoc(
      'reports-emergency',
      model.id.toString(),
      model.toJson(),
    );
  }

  Future<void> setMerge(ReportModel model) async {
    await _fs.setDocMerge(
      'reports-emergency',
      model.id.toString(),
      model.toJson(),
    );
  }
}
