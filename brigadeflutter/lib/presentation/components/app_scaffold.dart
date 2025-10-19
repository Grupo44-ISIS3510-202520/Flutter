import 'package:flutter/material.dart';
import 'app_bar_actions.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool backToDashboard;
  final bool showSignOut;
  final List<Widget>? extraActions;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.backToDashboard = true,
    this.showSignOut = true,
    this.extraActions,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backToDashboard ? backToDashboardButton(context) : null,
        title: Text(title),
        actions: [
          if (extraActions != null) ...extraActions!,
          if (showSignOut) signOutAction(context),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: body,
    );
  }
}
