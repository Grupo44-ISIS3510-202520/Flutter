import 'package:flutter/foundation.dart';
import '../navigation/dashboard_actions_factory.dart';
import '../navigation/dashboard_commands.dart';
import '../../data/models/meeting_point_model.dart';
import '../../domain/use_cases/dashboard/find_nearest_meeting_point.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardActionsFactory factory;
  final FindNearestMeetingPoint findNearestUseCase;

  DashboardViewModel({
    required this.factory,
    required this.findNearestUseCase,
  }) {

    actions = factory.mainGrid();
    emergency = factory.emergency();
    cprGuide = factory.cprGuide();
  }

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
      final result = await findNearestUseCase.call();

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
          nearestSubtext = 'Out of campus • ${result.distanceMeters.toStringAsFixed(0)} m';
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
        nearestSubtext = 'Out of campus • ${lastDistanceMeters!.toStringAsFixed(0)} m';
      } else {
        isOutsideCampus = false;
        nearestLabel = lastMeetingPoint!.name;
        nearestSubtext = '${lastDistanceMeters!.toStringAsFixed(0)} m';
      }
    }
    notifyListeners();
  }

  Future<void> forceRecalculate() async {
    _hasCalculated = false;
    await updateNearestMeetingPoint();
  }

  @override
  void dispose() {
    debugPrint('DashboardViewModel disposed — stacktrace:\n${StackTrace.current}');
    super.dispose();
  }





}