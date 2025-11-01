import 'dart:async';
import 'dart:isolate';
import 'package:brigadeflutter/data/models/report_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
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
  bool isOnline = true;

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
  Future<void> initConnectivityWatcher() async {
    // initialize state at startup
    offline = !(await connectivity.isOnline());
    _notify();

    // start listening for changes
    _connSub = Connectivity().onConnectivityChanged.listen((status) {
      final newOffline = (status == ConnectivityResult.none);
      if (newOffline != offline) {
        offline = newOffline;
        _notify();
      }
    });
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

  // fill location con GPS
  Future<bool> fillWithCurrentLocation() async {
    if (loadingLocation) return false;
    loadingLocation = true;
    _notify();

    try {
      final pos = await Future.any([
        fillLocation(),
        Future.delayed(const Duration(seconds: 3), () => null),
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
      final dir = await getApplicationDocumentsDirectory();
      final appPath = dir.path;


      await Isolate.spawn(
        openAIIsolateEntry,
        OpenAIIsolateMessage(receivePort.sendPort, typeName, apiKey, appPath),
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
      await tts
          .speak(text)
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () async => tts.stop(),
          );
    } catch (_) {}
  }

  // submits emergency report
  Future<int?> submit({required bool isOnline}) async {
    if (type.trim().isEmpty ||
        placeTime.trim().isEmpty ||
        description.trim().isEmpty) {
      return null;
    }

    if (submittingReport) return null;
    submittingReport = true;
    _notify();

    // check connectivity live (ignore passed param to avoid stale value)
    final online = await connectivity.isOnline();
    isOnline = online;
    offline = !online;
    _notify();

    try {
      // When online try remote call with timeout, otherwise enqueue locally
      if (online) {
        try {
          // adjust timeout as needed
          const timeoutDuration = Duration(seconds: 2);
          final id = await createReport(
            type: type,
            placeTime: placeTime,
            description: description,
            isFollowUp: isFollowUp,
            latitude: latitude,
            longitude: longitude,
            isOnline: true,
          ).timeout(timeoutDuration);
          _resetForm();
          return id;
        } on TimeoutException {
          // remote timed out — fallback to saving locally
          await createReport(
            type: type,
            placeTime: placeTime,
            description: description,
            isFollowUp: isFollowUp,
            latitude: latitude,
            longitude: longitude,
            isOnline: false,
          );
          return null;
        } catch (e) {
          // other remote error — fallback local
          await createReport(
            type: type,
            placeTime: placeTime,
            description: description,
            isFollowUp: isFollowUp,
            latitude: latitude,
            longitude: longitude,
            isOnline: false,
          );
          return null;
        }
      } else {
        // offline: save locally
        await createReport(
          type: type,
          placeTime: placeTime,
          description: description,
          isFollowUp: isFollowUp,
          latitude: latitude,
          longitude: longitude,
          isOnline: false,
        );
        _resetForm();
        return null;
      }
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
    _connSub?.cancel();
    _isDisposed = true;
    try {
      tts.stop();
    } catch (_) {}
    _luxSub?.cancel();
    super.dispose();
  }

  String get typeValue => type;
}
