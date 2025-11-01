import 'dart:ffi';

import 'package:brigadeflutter/data/models/report_model.dart';

import '../entities/report.dart';

abstract class ReportRepository {

  Future<void> createEmergencyReport({
    required String type,
    required String placeTime,
    required String description,
    required bool isFollowUp,
    double? latitude,
    double? longitude,
    bool isOnline = true,
  });

  Future<void> create(Report report);

  //sprint 3, strategies (no los implementé aún)
  Future<void> enqueue(Report report);
  Future<List<Report>> pending();
  Future<void> markSent(Report report);

  //new methods for local storage 
  Future<void> saveLocal(ReportModel model);
  Future<List<ReportModel>> listPending();
  Future<void> removeLocal(int id);
  Future<void> syncPending();
}