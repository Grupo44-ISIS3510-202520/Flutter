import 'package:flutter/foundation.dart';

import '../../data/entities/report.dart';
import '../../data/models/meeting_point_model.dart';
import '../../data/repositories/report_repository.dart';
import '../../domain/use_cases/dashboard/find_nearest_meeting_point.dart';
import '../navigation/dashboard_actions_factory.dart';
import '../navigation/dashboard_commands.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required this.factory,
    required this.findNearestUseCase,
    required this.reportRepository,
  }) {

    actions = factory.mainGrid();
    emergency = factory.emergency();
    cprGuide = factory.cprGuide();
  }

  final DashboardActionsFactory factory;
  final FindNearestMeetingPoint findNearestUseCase;
  final ReportRepository reportRepository;

  bool isOnline = true;
  List<DashboardActionCommand> actions = const [];
  late DashboardActionCommand emergency;
  late DashboardActionCommand cprGuide;

  String nearestLabel = 'Not calculated';
  String nearestSubtext = '';
  bool isFinding = false;
  bool locationAvailable = true;
  bool isOutsideCampus = false;
  double? lastDistanceMeters;
  MeetingPoint? lastMeetingPoint;
  bool _hasCalculated = false;

  void setOnline(bool v) {
    isOnline = v;
    notifyListeners();
  }

  Future<void> updateNearestMeetingPoint() async {
    if (_hasCalculated && !isFinding) {
      _updateDisplayFromCache();
      return;
    }

    isFinding = true;
    nearestLabel = 'Searching...';
    nearestSubtext = '';
    isOutsideCampus = false;
    locationAvailable = true;
    notifyListeners();

    try {
      final result = await findNearestUseCase
          .call()
          .timeout(const Duration(seconds: 8), onTimeout: () {
        throw LocationUnavailableException();
      });

      if (result == null) {
        nearestLabel = 'There are no registered meeting points';
        nearestSubtext = '';
        lastMeetingPoint = null;
        lastDistanceMeters = null;
        _hasCalculated = true;
      } else {
        lastMeetingPoint = result.point;
        lastDistanceMeters = result.distanceMeters;
        _hasCalculated = true;

        final maxDistance = findNearestUseCase.maxDistanceMeters;
        if (result.distanceMeters > maxDistance) {
          isOutsideCampus = true;
          nearestLabel = result.point.name;
          nearestSubtext =
          'Out of campus • ${result.distanceMeters.toStringAsFixed(0)} m';
        } else {
          isOutsideCampus = false;
          nearestLabel = result.point.name;
          nearestSubtext = '${result.distanceMeters.toStringAsFixed(0)} m';
        }
      }
    } on LocationUnavailableException {
      locationAvailable = false;
      nearestLabel = 'Location not available';
      nearestSubtext = "Follow the brigade's instructions";
      lastMeetingPoint = null;
      lastDistanceMeters = null;
      _hasCalculated = true;
    } catch (e) {
      nearestLabel = 'Error at point calculation';
      nearestSubtext = '';
      lastMeetingPoint = null;
      lastDistanceMeters = null;
      _hasCalculated = false;
    } finally {
      isFinding = false;
      notifyListeners();
    }
  }

  void _updateDisplayFromCache() {
    if (lastMeetingPoint != null && lastDistanceMeters != null) {
      final maxDistance = findNearestUseCase.maxDistanceMeters;
      if (lastDistanceMeters! > maxDistance) {
        isOutsideCampus = true;
        nearestLabel = lastMeetingPoint!.name;
        nearestSubtext =
        'Out of campus • ${lastDistanceMeters!.toStringAsFixed(0)} m';
      } else {
        isOutsideCampus = false;
        nearestLabel = lastMeetingPoint!.name;
        nearestSubtext =
        '${lastDistanceMeters!.toStringAsFixed(0)} m';
      }
    }
    notifyListeners();
  }

  Future<void> forceRecalculate() async {
    _hasCalculated = false;
    await updateNearestMeetingPoint();
  }

  // Sync pending reports on dashboard init
  Future<void> syncPendingReports() async {
    try {
      if (kDebugMode) {
        print('Dashboard: Starting sync of pending reports...');
      }
      
      final List<Report> pendingReports = await reportRepository.pending();
      if (kDebugMode) {
        print('Dashboard: Found ${pendingReports.length} pending reports to sync');
      }
      
      if (pendingReports.isEmpty) {
        return;
      }
      
      for (final Report report in pendingReports) {
        try {
          if (kDebugMode) {
            print('Dashboard: Syncing report ${report.reportId}...');
          }
          await reportRepository.create(report);
          await reportRepository.markSent(report);
          if (kDebugMode) {
            print('Dashboard: Successfully synced report ${report.reportId}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Dashboard: Failed to sync report ${report.reportId}: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Dashboard: Error syncing pending reports: $e');
      }
    }
  }

  @override
  void dispose() {
    debugPrint(
        'DashboardViewModel disposed — stacktrace:\n${StackTrace.current}');
    super.dispose();
  }
}
