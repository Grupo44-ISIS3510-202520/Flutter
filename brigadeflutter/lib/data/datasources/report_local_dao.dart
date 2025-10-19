import 'package:hive/hive.dart';
import '../../domain/models/report_model.dart';

// dao local para cola offline
class ReportLocalDao {
  static const _box = 'pending_reports';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_box)) {
      await Hive.openBox<Map>(_box);
    }
  }

  Future<void> savePending(ReportModel model) async {
    final box = Hive.box<Map>(_box);
    final key = model.id;
    await box.put(key, {
      'id': model.id,
      ...model.toJson(),
      'createdAtMs': model.createdAtMs,
    });
  }

  Future<List<ReportModel>> listPending() async {
    final box = Hive.box<Map>(_box);
    return box.values
        .map((m) => ReportModel.fromJson(
              Map<String, dynamic>.from(m),
              id: (m['id'] as num).toInt(),
            ))
        .toList();
  }

  Future<void> remove(int id) async {
    final box = Hive.box<Map>(_box);
    await box.delete(id);
  }

  Future<void> replaceId({required int tempId, required int finalId}) async {
    final box = Hive.box<Map>(_box);
    final data = box.get(tempId);
    if (data == null) return;
    data['id'] = finalId;
    box
      ..delete(tempId)
      ..put(finalId, data);
  }
}
