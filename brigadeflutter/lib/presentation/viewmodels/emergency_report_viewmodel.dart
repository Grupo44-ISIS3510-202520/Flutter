import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

import '../../helpers/workers/openai_isolate.dart';
import '../../data/entities/report.dart';
import '../../data/services_external/ambient_light_service.dart';
import '../../data/services_external/connectivity_service.dart';
import '../../data/services_external/notitication_service.dart';
import '../../data/services_external/openai_service.dart';
import '../../data/services_external/screen_brightness_service.dart';
import '../../data/services_external/tts_service.dart';
import '../../domain/use_cases/adjust_brightness_from_ambient.dart';
import '../../domain/use_cases/create_emergency_report.dart';
import '../../domain/use_cases/fill_location.dart';
import '../../domain/use_cases/get_current_user.dart';



class EmergencyReportViewModel extends ChangeNotifier {
  EmergencyReportViewModel({
    required this.createReport,
    required this.fillLocation,
    required this.adjustBrightness,
    required this.getCurrentUser,
    required this.ambient,
    required this.screen,
    required this.openai,
    required this.tts,
    required this.connectivity,
    required this.notificationService,
  });
  final CreateEmergencyReport createReport;
  final FillLocation fillLocation;
  final AdjustBrightnessFromAmbient adjustBrightness;
  final GetCurrentUser getCurrentUser;
  final AmbientLightService ambient;
  final ScreenBrightnessService screen;
  final OpenAIService openai;
  final TtsService tts;
  final ConnectivityService connectivity;
  final NotificationService notificationService;

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

  // Callback for successful report sync notifications
  Function(String reportId, DateTime timestamp)? onReportSynced;

  // state forms
  String type = '';
  String place = '';
  String description = '';
  bool isFollowUp = false;
  int elapsedTime = 0; // in ms or s
  double? latitude;
  double? longitude;
  String? audioUrl;
  String? imageUrl;
  int uiid = 0;
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
    try {
      offline = !(await connectivity.isOnline());
      isOnline = !offline;
      if (kDebugMode) {
        print('EmergencyReport connectivity initialized: offline=$offline, isOnline=$isOnline');
      }
      _notify();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing connectivity: $e');
      }
    }

    // start listening for changes
    _connSub = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> status,
    ) async {
      final bool newOffline = status.contains(ConnectivityResult.none);
      if (kDebugMode) {
        print('EmergencyReport connectivity changed: status=$status, newOffline=$newOffline, currentOffline=$offline');
      }
      
      if (newOffline != offline) {
        final bool wasOffline = offline;
        offline = newOffline;
        isOnline = !offline;
        if (kDebugMode) {
          print('EmergencyReport state updated: wasOffline=$wasOffline, offline=$offline, isOnline=$isOnline');
        }
        _notify();
        
        // If we just came back online, sync pending reports
        if (wasOffline && !offline) {
          if (kDebugMode) {
            print('EmergencyReport: Detected transition from offline to online, starting sync...');
          }
          // Add small delay to ensure connection is stable
          await Future<void>.delayed(const Duration(milliseconds: 500));
          await _syncPendingReports();
        } else if (!wasOffline && offline) {
          if (kDebugMode) {
            print('EmergencyReport: Detected transition from online to offline');
          }
        }
      } else {
        if (kDebugMode) {
          print('EmergencyReport: Connectivity status unchanged (offline=$offline)');
        }
      }
    });
  }

  // Sync pending reports and notify about successful syncs
  Future<void> _syncPendingReports() async {
    try {
      if (kDebugMode) {
        print('EmergencyReport: Starting sync of pending reports...');
      }
      
      final List<Report> pendingReports = await createReport.repo.pending();
      if (kDebugMode) {
        print('EmergencyReport: Found ${pendingReports.length} pending reports to sync');
        for (final report in pendingReports) {
          print('  - Report ID: ${report.reportId}, Type: ${report.type}, Timestamp: ${report.timestamp}');
        }
      }
      
      if (pendingReports.isEmpty) {
        if (kDebugMode) {
          print('EmergencyReport: No pending reports to sync');
        }
        return;
      }
      
      // Sync each report sequentially to avoid Hive concurrency issues
      int syncedCount = 0;
      int failedCount = 0;
      
      for (final Report report in pendingReports) {
        try {
          if (kDebugMode) {
            print('EmergencyReport: Syncing report ${report.reportId}...');
          }
          
          // All reports use F## nomenclature, just use the existing ID
          final Report updatedReport = Report(
            reportId: report.reportId,
            type: report.type,
            description: report.description,
            isFollowUp: report.isFollowUp,
            timestamp: report.timestamp,
            elapsedTime: report.elapsedTime,
            place: report.place,
            latitude: report.latitude,
            longitude: report.longitude,
            audioUrl: report.audioUrl,
            imageUrl: report.imageUrl,
            uiid: report.uiid,
            userId: report.userId,
          );
          
          await createReport.repo.create(updatedReport);
          if (kDebugMode) {
            print('EmergencyReport: Created report in Firestore with ID ${report.reportId}');
          }
          
          await createReport.repo.markSent(report);
          if (kDebugMode) {
            print('EmergencyReport: Marked report as sent');
          }
          
          syncedCount++;
          
          // Show local notification on main thread
          if (kDebugMode) {
            print('EmergencyReport: Attempting to show notification for report ${report.reportId}');
          }
          
          // Schedule notification on next frame to ensure it runs on main thread
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await notificationService.showReportSyncedNotification(
                reportId: report.reportId,
                timestamp: report.timestamp,
              );
              if (kDebugMode) {
                print('EmergencyReport: Notification shown for report ${report.reportId}');
              }
            } catch (e) {
              if (kDebugMode) {
                print('EmergencyReport: Failed to show notification: $e');
              }
            }
          });
          
          // Notify about successful sync
          if (onReportSynced != null) {
            onReportSynced!(report.reportId, report.timestamp);
            if (kDebugMode) {
              print('EmergencyReport: Notified UI about synced report ${report.reportId}');
            }
          }
        } catch (e, stackTrace) {
          failedCount++;
          if (kDebugMode) {
            print('EmergencyReport: Failed to sync report ${report.reportId}: $e');
            print('Stack trace: $stackTrace');
          }
        }
      }
      
      if (kDebugMode) {
        print('EmergencyReport: Sync complete. Synced: $syncedCount, Failed: $failedCount');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('EmergencyReport: Error syncing pending reports: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  // auto brightness toggle
  void toggleAutoBrightness(bool value) {
    autoBrightnessOn = value;
    _notify();
  }

  // changes in form fields
  void onTypeChanged(String value) => type = value;
  void onPlaceChanged(String value) {
    place = value;
    placeFromGps = false;
  }

  void onDescriptionChanged(String value) => description = value;
  void onFollowChanged(bool value) {
    isFollowUp = value;
    _notify();
  }
  
  void onElapsedTimeChanged(int value) => elapsedTime = value;
  void onAudioUrlChanged(String? value) => audioUrl = value;
  void onImageUrlChanged(String? value) => imageUrl = value;
  void onUiidChanged(int value) => uiid = value;

  // clears ubicación GPS
  void clearGpsLocation() {
    latitude = null;
    longitude = null;
    if (placeFromGps) place = '';
    placeFromGps = false;
    _notify();
  }

  // fill location con GPS
  Future<bool> fillWithCurrentLocation() async {
    if (loadingLocation) return false;
    loadingLocation = true;
    _notify();

    try {
      final ({double lat, double lng})? pos = await Future.any(
        <Future<({double lat, double lng})?>>[
          fillLocation(),
          Future.delayed(const Duration(seconds: 3), () => null),
        ],
      );

      if (pos == null) {
        if (placeFromGps) {
          clearGpsLocation();
        } else {
          loadingLocation = false;
          _notify();
        }
        return false;
      }

      final DateTime now = DateTime.now();
      place =
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

      final bool isOnline = await connectivity.isOnline();
      if (!isOnline) {
        await _handleOfflineVoice();
        return;
      }

      final ReceivePort receivePort = ReceivePort();
      final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      final String typeName = type.isEmpty ? 'Emergency' : type;
      final Directory dir = await getApplicationDocumentsDirectory();
      final String appPath = dir.path;

      await Isolate.spawn(
        openAIIsolateEntry,
        OpenAIIsolateMessage(receivePort.sendPort, typeName, apiKey, appPath),
      );

      final String result = await receivePort.first as String;
      final String text = result.startsWith('Error:')
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
  Future<String?> submit({required bool isOnline, DateTime? timestamp}) async {
    if (type.trim().isEmpty ||
        place.trim().isEmpty ||
        description.trim().isEmpty) {
      return null;
    }

    if (submittingReport) return null;
    submittingReport = true;
    _notify();

    // check connectivity live (ignore passed param to avoid stale value)
    final bool online = await connectivity.isOnline();
    isOnline = online;
    offline = !online;
    _notify();

    try {
      // When online try remote call with timeout, otherwise enqueue locally
      if (online) {
        try {
          // adjust timeout as needed
          const Duration timeoutDuration = Duration(seconds: 2);
          final String reportId = await createReport(
            type: type,
            place: place,
            description: description,
            isFollowUp: isFollowUp,
            elapsedTime: elapsedTime,
            latitude: latitude,
            longitude: longitude,
            audioUrl: audioUrl,
            imageUrl: imageUrl,
            uiid: uiid,
            userId: getCurrentUser()?.uid ?? '',
            isOnline: true,
            timestamp: timestamp,
          ).timeout(timeoutDuration);
          _resetForm();
          return reportId;
        } on TimeoutException {
          // remote timed out — fallback to saving locally
          await createReport(
            type: type,
            place: place,
            description: description,
            isFollowUp: isFollowUp,
            elapsedTime: elapsedTime,
            latitude: latitude,
            longitude: longitude,
            audioUrl: audioUrl,
            imageUrl: imageUrl,
            uiid: uiid,
            userId: getCurrentUser()?.uid ?? '',
            isOnline: false,
            timestamp: timestamp,
          );
          return null;
        } catch (e) {
          // other remote error — fallback local
          await createReport(
            type: type,
            place: place,
            description: description,
            isFollowUp: isFollowUp,
            elapsedTime: elapsedTime,
            latitude: latitude,
            longitude: longitude,
            audioUrl: audioUrl,
            imageUrl: imageUrl,
            uiid: uiid,
            userId: getCurrentUser()?.uid ?? '',
            isOnline: false,
            timestamp: timestamp,
          );
          return null;
        }
      } else {
        // offline: save locally
        await createReport(
          type: type,
          place: place,
          description: description,
          isFollowUp: isFollowUp,
          elapsedTime: elapsedTime,
          latitude: latitude,
          longitude: longitude,
          audioUrl: audioUrl,
          imageUrl: imageUrl,
          uiid: uiid,
          userId: getCurrentUser()?.uid ?? '',
          isOnline: false,
          timestamp: timestamp,
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
    place = '';
    description = '';
    isFollowUp = false;
    elapsedTime = 0;
    latitude = null;
    longitude = null;
    audioUrl = null;
    imageUrl = null;
    uiid = 0;
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
