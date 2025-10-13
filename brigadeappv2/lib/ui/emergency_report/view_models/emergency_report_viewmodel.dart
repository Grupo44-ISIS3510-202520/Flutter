import 'package:brigadeappv2/domain/emergency_report/emergency_report.dart';
import 'package:brigadeappv2/data/repositories/emergency_report/emergency_report_repository.dart';
import 'package:flutter/material.dart';

class EmergencyReportViewmodel extends ChangeNotifier {
  final EmergencyReportRepository _emergencyReportRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  EmergencyReportViewmodel({
    required EmergencyReportRepository emergencyReportRepository,
  }) : _emergencyReportRepository = emergencyReportRepository;

  Future<void> createEmergencyReport(EmergencyReport report) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _emergencyReportRepository.createEmergencyReport(report);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}