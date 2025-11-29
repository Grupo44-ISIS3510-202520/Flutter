import 'package:hive/hive.dart';
import '../models/report_model.dart';

// dao local para cola offline
class ReportLocalDao {
  static const String _box = 'pending_reports';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_box)) {
      await Hive.openBox<Map>(_box);
    }
  }

  Future<void> savePending(ReportModel model) async {
    final Box<Map> box = Hive.box<Map>(_box);
    await box.put(model.reportId, <dynamic, dynamic>{
      ...model.toJson(),
    });
  }

  Future<List<ReportModel>> listPending() async {
    final Box<Map> box = Hive.box<Map>(_box);
    return box.values
        .map(
          (Map m) => ReportModel.fromJson(
            Map<String, dynamic>.from(m),
          ),
        )
        .toList();
  }

  Future<void> remove(String reportId) async {
    final Box<Map> box = Hive.box<Map>(_box);
    await box.delete(reportId);
  }

  Future<void> clearAll() async {
    final Box<Map> box = Hive.box<Map>(_box);
    await box.clear();
  }

  Future<void> replaceId({
    required String tempId,
    required String finalId,
  }) async {
    final Box<Map> box = Hive.box<Map>(_box);
    final Map? data = box.get(tempId);
    if (data == null) return;
    data['reportId'] = finalId;
    box
      ..delete(tempId)
      ..put(finalId, data);
  }
}
