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
  bool submitting = false;

  void onTypeChanged(String v) { type = v; notifyListeners(); }
  void onPlaceTimeChanged(String v) { placeTime = v; notifyListeners(); }
  void onDescriptionChanged(String v) { description = v; notifyListeners(); }
  void onFollowChanged(bool v) { isFollowUp = v; notifyListeners(); }

  Future<int?> submit({required bool isOnline}) async {
    if (type.isEmpty || placeTime.isEmpty || description.isEmpty) return null;
    submitting = true; notifyListeners();

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
      type=''; placeTime=''; description=''; isFollowUp=false; latitude=null; longitude=null;
      submitting = false; notifyListeners();
      return id;
    } catch (_) {
      submitting = false; notifyListeners();
      return null;
    }
  }

    Future<void> fillWithCurrentLocation() async {
    submitting = true; notifyListeners();                                // update state
    final pos = await fillLocation();
    if (pos != null) {
      final now = DateTime.now();
      placeTime = 'Lat ${pos.lat.toStringAsFixed(5)}, '
                  'Lon ${pos.lng.toStringAsFixed(5)}'
                  ' • ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';
      latitude = pos.lat; longitude = pos.lng;
    }
    submitting = false; notifyListeners();                                // update state
  }
}
