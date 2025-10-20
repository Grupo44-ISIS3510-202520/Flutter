import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/app_services/create_emergency_report.dart';
import '../../domain/app_services/fill_location.dart';

class EmergencyReportViewModel extends ChangeNotifier {
  final CreateEmergencyReport createReport;
  final FillLocation fillLocation;
  EmergencyReportViewModel({required this.createReport, required this.fillLocation});

  String type = '';
  String placeTime = '';
  String description = '';
  bool isFollowUp = false;
  double? latitude;
  double? longitude;

  bool submittingReport = false;
  bool loadingLocation = false;
  bool placeFromGps = false;

  void onTypeChanged(String v) { type = v; }
   void onPlaceTimeChanged(String v) {
    placeTime = v;
    placeFromGps = false;
  }
  void onDescriptionChanged(String v) { description = v; }
  void onFollowChanged(bool v) { isFollowUp = v; notifyListeners(); }

   void clearGpsLocation() {
    latitude = null;
    longitude = null;
    if (placeFromGps) {
      placeTime = '';
    }
    placeFromGps = false;
    notifyListeners();
  }

  Future<bool> fillWithCurrentLocation() async {
    if (loadingLocation) return false;
    loadingLocation = true; notifyListeners();
    try {
      final pos = await Future.any([
        fillLocation(),
        Future.delayed(const Duration(seconds: 8), () => null),
      ]);

      if (pos == null) {
        if (placeFromGps) {
          clearGpsLocation();
        } else {
          loadingLocation = false; notifyListeners();
        }
        return false;
      }

      final now = DateTime.now();
      placeTime =
          'Lat ${pos.lat.toStringAsFixed(5)}, Lon ${pos.lng.toStringAsFixed(5)}'
          ' • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      latitude = pos.lat;
      longitude = pos.lng;
      placeFromGps = true;
      notifyListeners();
      return true;
    } finally {
      loadingLocation = false; notifyListeners();
    }
  }

  Future<int?> submit({required bool isOnline}) async {
    if (type.trim().isEmpty || placeTime.trim().isEmpty || description.trim().isEmpty) return null;
    if (submittingReport) return null;
    submittingReport = true; notifyListeners();
    try {
      final id = await createReport(
        type: type,
        placeTime: placeTime,
        description: description,
        isFollowUp: isFollowUp,
        latitude: latitude,
        longitude: longitude,
        isOnline: isOnline,
      );
      _reset();
      return id;
    } finally {
      submittingReport = false; notifyListeners();
    }
  }

  void _reset() {
    type = '';
    placeTime = '';
    description = '';
    isFollowUp = false;
    latitude = null;
    longitude = null;
    placeFromGps = false;
    notifyListeners();
  }
}
