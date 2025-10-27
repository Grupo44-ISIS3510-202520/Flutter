import 'package:flutter/material.dart';

abstract class DashboardActionCommand {
  String get label;
  IconData get icon;
  void execute(BuildContext context); // navega o muestra diálogos
}

// notificaciones
class GoNotificationsCommand implements DashboardActionCommand {
  @override String get label => 'Notifications';
  @override IconData get icon => Icons.notifications;
  @override void execute(BuildContext context) {
    Navigator.of(context).pushNamed('/notification');
  }
}

// protocolos
class GoProtocolsCommand implements DashboardActionCommand {
  @override String get label => 'Protocols';
  @override IconData get icon => Icons.menu_book;
  @override void execute(BuildContext context) {
    Navigator.of(context).pushNamed('/protocols');
  }
}

// training
class GoTrainingCommand implements DashboardActionCommand {
  @override String get label => 'Training';
  @override IconData get icon => Icons.school;
  @override void execute(BuildContext context) {
    Navigator.of(context).pushNamed('/training');
  }
}

// perfil
class GoProfileCommand implements DashboardActionCommand {
  @override String get label => 'Profile';
  @override IconData get icon => Icons.person;
  @override void execute(BuildContext context) {
    Navigator.of(context).pushNamed('/profile');
  }
}

// emergencia grande
class GoEmergencyReportCommand implements DashboardActionCommand {
  @override String get label => 'EMERGENCY';
  @override IconData get icon => Icons.notifications_active;
  @override void execute(BuildContext context) {
    Navigator.of(context).pushNamed('/report');
  }
}

// guía RCP
class GoCprGuideCommand implements DashboardActionCommand {
  @override String get label => 'CPR Guide';
  @override IconData get icon => Icons.favorite;
  @override void execute(BuildContext context) {
    // TODO: define ruta a guía RCP cuando exista
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CPR Guide is coming soon')),
    );
  }
}
