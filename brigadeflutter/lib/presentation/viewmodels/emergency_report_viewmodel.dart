import 'dart:async';
import 'dart:isolate';
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

  // estado brillo
  bool autoBrightnessSupported = false;
  bool autoBrightnessOn = false;
  double currentBrightness = 0.0;
  StreamSubscription<double>? _luxSub;

  //voice instructions -> concurrencia
  bool generatingVoice = false;
  bool offline = false;

  Future<void> initBrightness() async {
    autoBrightnessSupported = ambient.isSupported();
    try {
      currentBrightness = await screen.getBrightness();
    } catch (_) {}
    notifyListeners(); // update state
  }

  // voice: asegura bloqueo del botón, fallback offline y cleanup al salir
  Future<void> onVoiceInstructions() async {
  if (generatingVoice) return;
  generatingVoice = true;
  notifyListeners();

  try {
    await tts.init(lang: 'en-US');

    final isOnline = await connectivity.isOnline();
    if (!isOnline) {
      offline = true;
      notifyListeners();

      // small delay to ensure TTS engine is ready
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        await tts.speak('You have no internet, please remain calm.')
        .timeout(const Duration(seconds: 5), onTimeout: () async {
  await tts.stop();
        }) ;
      } catch (_) {
        // if TTS fails silently, just reset state
      }
      return;
    }

    final typeName = (type.isEmpty) ? 'Emergency' : type;

    // --- create isolate communication ports ---
    final receivePort = ReceivePort();
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    await Isolate.spawn(
      openAIIsolateEntry,
      OpenAIIsolateMessage(receivePort.sendPort, typeName, apiKey),
    );

    // wait for message from isolate
    final text = await receivePort.first as String;

    // play result
    if (text.startsWith('Error:')) {
      await tts.speak('An error occurred generating the voice instructions.');
    } else {
      await tts.speak(text);
    }
  } catch (e) {
    // fallback if TTS or isolate fails
    try {
      await tts.speak('An unexpected error occurred.');
    } catch (_) {}
  } finally {
    generatingVoice = false;
    notifyListeners();
  }
}

  String type = '';
  String placeTime = '';
  String description = '';
  bool isFollowUp = false;
  double? latitude;
  double? longitude;

  bool submittingReport = false;
  bool loadingLocation = false;
  bool placeFromGps = false;

  void toggleAutoBrightness(bool v) {
    autoBrightnessOn = v;
    notifyListeners();
  }

  void onTypeChanged(String v) {
    type = v;
  }

  void onPlaceTimeChanged(String v) {
    placeTime = v;
    placeFromGps = false;
  }

  void onDescriptionChanged(String v) {
    description = v;
  }

  void onFollowChanged(bool v) {
    isFollowUp = v;
    notifyListeners();
  }

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
    loadingLocation = true;
    notifyListeners();
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
          notifyListeners();
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
      loadingLocation = false;
      notifyListeners();
    }
  }

  Future<int?> submit({required bool isOnline}) async {
    if (type.trim().isEmpty ||
        placeTime.trim().isEmpty ||
        description.trim().isEmpty) {
      return null;
    }
    if (submittingReport) return null;
    submittingReport = true;
    notifyListeners();
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
      submittingReport = false;
      notifyListeners();
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

  @override
  void dispose() {
    _luxSub?.cancel();
    super.dispose();
  }

  String get typeValue => type;
}
