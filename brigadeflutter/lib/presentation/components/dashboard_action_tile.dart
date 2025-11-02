import 'package:flutter/material.dart';
import '../navigation/dashboard_commands.dart';

class DashboardActionTile extends StatelessWidget {
  const DashboardActionTile({super.key, required this.command});
  final DashboardActionCommand command;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => command.execute(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(command.icon, size: 42, color: Colors.blue[600]),
              const SizedBox(height: 8),
              Text(
                command.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
