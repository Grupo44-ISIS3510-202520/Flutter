import 'package:flutter/foundation.dart';
import '../../core/utils/constants.dart'; // si usas roles/flags
import '../navigation/dashboard_actions_factory.dart';
import '../navigation/dashboard_commands.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardActionsFactory factory;

  DashboardViewModel({required this.factory}) {
    // update state
    actions = factory.mainGrid();
    emergency = factory.emergency();
    cprGuide = factory.cprGuide();
  }

  bool isOnline = true; // si ya tienes observer global, puedes inyectarlo
  List<DashboardActionCommand> actions = const [];
  late DashboardActionCommand emergency;
  late DashboardActionCommand cprGuide;

  // opcional: setear conectividad desde fuera
  void setOnline(bool v) { isOnline = v; notifyListeners(); } // update state
}
