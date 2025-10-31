import 'package:brigadeflutter/core/utils/id_generator.dart';
import 'package:brigadeflutter/data/services_external/connectivity_service.dart';

import '../entities/report.dart';
import '../repositories/report_repository.dart';
import '../datasources/report_firestore_dao.dart';
import '../datasources/report_local_dao.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportFirestoreDao remote;
  final ReportLocalDao local;
  final ConnectivityService? connectivity;
  final FirestoreIdGenerator idGen;
  ReportRepositoryImpl({required this.remote, required this.local, this.connectivity, required this.idGen,});

  @override
  Future<void> create(Report report) async {
    // helper para construir ReportModel con id elegido
    ReportModel _modelWithId(int id) => ReportModel(
          id: id,
          type: report.type,
          placeTime: report.placeTime,
          description: report.description,
          isFollowUp: report.isFollowUp,
          latitude: report.latitude,
          longitude: report.longitude,
          createdAtMs: report.createdAt.millisecondsSinceEpoch,
        );

    final online = (await connectivity?.isOnline()) ?? false;
    if (!online) {
      // si estamos offline, guardamos local con id temporal (negativo para distinguir)
      final tempId = -DateTime.now().millisecondsSinceEpoch;
      await local.savePending(_modelWithId(tempId));
      return;
    }

    try {
      // intentamos obtener id consistente desde Firestore (tu requisito)
      final id = await idGen.nextReportId();
      final model = _modelWithId(id);

      await remote.set(model);

      // si el report pasado tenía un id temporal (negativo), eliminamos la copia local
      if (report.id < 0) {
        await local.remove(report.id);
      } else {
        // intentar limpiar cualquier posible pendiente con el mismo id
        await local.remove(id);
      }
    } catch (e) {
      // si falla la obtención del id o la creación remota, encolamos localmente con id temporal
      final tempId = -DateTime.now().millisecondsSinceEpoch;
      await local.savePending(_modelWithId(tempId));
    }
  }

  
  @override
  Future<void> enqueue(Report report) => local.savePending(ReportModel.fromEntity(report));

  @override
  Future<List<Report>> pending() async =>
      (await local.listPending()).map((e) => e.toEntity()).toList();

  @override
  Future<void> markSent(Report report) => local.remove(report.id);
}
