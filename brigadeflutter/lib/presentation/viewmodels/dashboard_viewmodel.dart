import 'package:flutter/foundation.dart';
import '../../core/utils/constants.dart';
import '../navigation/dashboard_actions_factory.dart';
import '../navigation/dashboard_commands.dart';
import '../../data/models/meeting_point_model.dart';
import '../../data/repositories/meeting_point_repository.dart';
import '../../domain/use_cases/dashboard/find_nearest_meeting_point.dart';
import '../../data/services_external/location/location_service.dart';

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

  String nearestLabel = 'No calculado';
  String nearestSubtext = '';
  bool isFinding = false;
  bool locationAvailable = true;
  bool isOutsideCampus = false;
  double? lastDistanceMeters;
  MeetingPoint? lastMeetingPoint;

  void setOnline(bool v) {
    isOnline = v;
    notifyListeners();
  }

  Future<void> updateNearestMeetingPoint() async {
    isFinding = true;
    nearestLabel = 'Buscando...';
    nearestSubtext = '';
    isOutsideCampus = false;
    locationAvailable = true;
    notifyListeners();

    try {
      final result = await findNearestUseCase.call();

      if (result == null) {
        nearestLabel = 'No hay puntos registrados';
        nearestSubtext = '';
        lastMeetingPoint = null;
        lastDistanceMeters = null;
      } else {
        lastMeetingPoint = result.point;
        lastDistanceMeters = result.distanceMeters;

        final maxDistance = findNearestUseCase.maxDistanceMeters;
        if (result.distanceMeters > maxDistance) {
          isOutsideCampus = true;
          nearestLabel = result.point.name;
          nearestSubtext = 'Fuera del campus • ${result.distanceMeters.toStringAsFixed(0)} m';
        } else {
          isOutsideCampus = false;
          nearestLabel = result.point.name;
          nearestSubtext = '${result.distanceMeters.toStringAsFixed(0)} m';
        }
      }
    } on LocationUnavailableException {
      locationAvailable = false;
      nearestLabel = 'Ubicación no disponible';
      nearestSubtext = 'Sigue las indicaciones de los brigadistas';
      lastMeetingPoint = null;
      lastDistanceMeters = null;
    } catch (e) {
      nearestLabel = 'Error al calcular punto';
      nearestSubtext = '';
      lastMeetingPoint = null;
      lastDistanceMeters = null;
    } finally {
      isFinding = false;
      notifyListeners();
    }
  }
}
