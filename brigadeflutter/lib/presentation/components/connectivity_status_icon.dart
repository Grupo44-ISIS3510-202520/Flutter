import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

/// A visual indicator widget that displays the current connectivity status.
/// This widget is NOT a button - it only shows the status visually.
///
/// - Green icon: User is online
/// - Red icon: User is offline
class ConnectivityStatusIcon extends StatelessWidget {
  const ConnectivityStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (BuildContext context, AuthViewModel authVM, Widget? child) {
        final bool isOnline = authVM.isOnline;

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            ),
            child: Icon(
              Icons.wifi,
              color: isOnline ? Colors.green : Colors.red,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
