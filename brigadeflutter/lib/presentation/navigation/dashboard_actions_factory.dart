import 'dashboard_commands.dart';

class DashboardActionsFactory {
  // se puede parametrizar por role/flags
  List<DashboardActionCommand> mainGrid() {
    return <DashboardActionCommand>[
      GoNotificationsCommand(),
      GoProtocolsCommand(),
      GoTrainingCommand(),
      GoProfileCommand(),
    ];
  }

  GoEmergencyReportCommand emergency() => GoEmergencyReportCommand();
  GoCprGuideCommand cprGuide() => GoCprGuideCommand();
}
