import 'dart:async';
import 'dart:isolate';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/use_cases/create_emergency_report.dart';
import '../../domain/use_cases/fill_location.dart';
import '../../domain/use_cases/adjust_brightness_from_ambient.dart';
import '../../data/services_external/ambient_light_service.dart';
import '../../data/services_external/screen_brightness_service.dart';
import '../../data/services_external/connectivity_service.dart';
import '../../data/services_external/openai_service.dart';
import '../../data/services_external/tts_service.dart';
import '../../core/workers/openai_isolate.dart';

class EmergencyReportViewModel extends ChangeNotifier {
  final CreateEmergencyReport createReport;
  final FillLocation fillLocation;
  final AdjustBrightnessFromAmbient adjustBrightness;
  final AmbientLightService ambient;
  final ScreenBrightnessService screen;
  final OpenAIService openai;
  final TtsService tts;
  final ConnectivityService connectivity;

  EmergencyReportViewModel({
    required this.createReport,
    required this.fillLocation,
    required this.adjustBrightness,
    required this.ambient,
    required this.screen,
    required this.openai,
    required this.tts,
    required this.connectivity,
  });

  // state
  bool autoBrightnessSupported = false;
  bool autoBrightnessOn = false;
  double currentBrightness = 0.0;
  StreamSubscription<double>? _luxSub;
  StreamSubscription? _connSub;

  // voice instructions
  bool generatingVoice = false;
  bool offline = false;

  // state forms
  String type = '';
  String placeTime = '';
  String description = '';
  bool isFollowUp = false;
  double? latitude;
  double? longitude;
  bool submittingReport = false;
  bool loadingLocation = false;
  bool placeFromGps = false;
  bool _isDisposed = false;

  void _notify() {
       if (!_isDisposed) notifyListeners();
  }
  // brightness initialization
  Future<void> initBrightness() async {
    autoBrightnessSupported = ambient.isSupported();
    try {
      currentBrightness = await screen.getBrightness();
    } catch (_) {}
    _notify();
  }

  // auto brightness toggle
  void toggleAutoBrightness(bool value) {
    autoBrightnessOn = value;
    _notify();
  }

  // changes in form fields
  void onTypeChanged(String value) => type = value;
  void onPlaceTimeChanged(String value) {
    placeTime = value;
    placeFromGps = false;
  }
  void onDescriptionChanged(String value) => description = value;
  void onFollowChanged(bool value) {
    isFollowUp = value;
    _notify();
  }

  // clears ubicación GPS
  void clearGpsLocation() {
    latitude = null;
    longitude = null;
    if (placeFromGps) placeTime = '';
    placeFromGps = false;
    _notify();
  }

//   Future<void> initConnectivityWatcher() async {
//   // Listen to changes
//   _connSub = Connectivity().onConnectivityChanged.listen((status) async {
//     if (status != ConnectivityResult.none) {
//       await syncPendingReports();
//     }
//   });
// }

// Sync pending reports when back online
// Future<void> syncPendingReports() async {
//   try {
//     final pending = await createReport.repo.local.listPending();
//     for (final report in pending) {
//       await createReport.repo.remote.createEmergencyReport(
//         type: report.type,
//         placeTime: report.placeTime,
//         description: report.description,
//         isFollowUp: report.isFollowUp,
//         latitude: report.latitude,
//         longitude: report.longitude,
//       );
//       await createReport.repo.local.remove(report.id);
//     }
//   } catch (e) {
//     // log or ignore, will retry next time
//   }
// }
  // fill location con GPS
  Future<bool> fillWithCurrentLocation() async {
    if (loadingLocation) return false;
    loadingLocation = true;
    _notify();

    try {
      final pos = await Future.any([
        fillLocation(),
        Future.delayed(const Duration(seconds: 8), () => null),
      ]);

      if (pos == null) {
        if (placeFromGps) {
          clearGpsLocation();
        } else {
          loadingLocation = false;
          _notify();
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
      return true;
    } finally {
      loadingLocation = false;
      _notify();
    }
  }

  // generates voice instructions
  Future<void> onVoiceInstructions() async {
    if (generatingVoice) return;

    generatingVoice = true;
    _notify();

    try {
      await tts.init(lang: 'en-US');

      final isOnline = await connectivity.isOnline();
      if (!isOnline) {
        await _handleOfflineVoice();
        return;
      }

      final receivePort = ReceivePort();
      final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      final typeName = type.isEmpty ? 'Emergency' : type;

      await Isolate.spawn(
        openAIIsolateEntry,
        OpenAIIsolateMessage(receivePort.sendPort, typeName, apiKey),
      );

      final result = await receivePort.first as String;
      final text = result.startsWith('Error:')
          ? 'Remain calm. At the moment, we’re unable to generate voice instructions.'
          : result;
      //bool _isDisposed = false;
      _speakVoiceInstructions(text);
      // await tts.speak(text);

    } catch (_) {
      await _safeSpeak('An unexpected error occurred.');
    } finally {
      generatingVoice = false;
      _notify();
    }
  }


Future<void> _speakVoiceInstructions(String text) async {
  await tts.speak(text);
  if (_isDisposed) return; // prevenir notifyListeners() luego del dispose
  _notify();
}
  // handles offline voice scenario
  Future<void> _handleOfflineVoice() async {
    offline = true;
    _notify();

    await Future.delayed(const Duration(milliseconds: 300));
    await _safeSpeak('You have no internet, please remain calm.');
  }

  // safe speak with timeout
  Future<void> _safeSpeak(String text) async {
    try {
      await tts.speak(text).timeout(
        const Duration(seconds: 5),
        onTimeout: () async => tts.stop(),
      );
    } catch (_) {}
  }

  // submits emergency report
  Future<int?> submit({required bool isOnline}) async {
    if (type.trim().isEmpty || placeTime.trim().isEmpty || description.trim().isEmpty) {
      return null;
    }

    if (submittingReport) return null;
    submittingReport = true;
    _notify();

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
      _resetForm();
      return id;
    } finally {
      submittingReport = false;
      _notify();
    }
  }

  // form reset
  void _resetForm() {
    type = '';
    placeTime = '';
    description = '';
    isFollowUp = false;
    latitude = null;
    longitude = null;
    placeFromGps = false;
    _notify();
  }

  @override
  void dispose() {
    _isDisposed = true; 
    try{
      tts.stop();
    }
    catch(_){}
    _luxSub?.cancel();
    super.dispose();
  }

  String get typeValue => type;
}
