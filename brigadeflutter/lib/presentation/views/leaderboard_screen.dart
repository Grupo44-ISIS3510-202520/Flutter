import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/connectivity_status_icon.dart';
import '../viewmodels/leaderboard_viewmodel.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaderboardViewModel vm = context.watch<LeaderboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: const <Widget>[
          ConnectivityStatusIcon(),
        ],
      ),
      backgroundColor: const Color(0xFFF3F5F8),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.entries.length,
              itemBuilder: (BuildContext context, int index) {
                final LeaderboardEntry entry = vm.entries[index];
                final String emailPrefix = entry.email.split('@').first;
                final IconData? medalIcon = index == 0
                    ? Icons.emoji_events
                    : index == 1
                        ? Icons.emoji_events_outlined
                        : index == 2
                            ? Icons.military_tech
                            : null;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: medalIcon != null
                        ? Icon(
                            medalIcon,
                            color: index == 0
                                ? Colors.amber
                                : index == 1
                                    ? Colors.grey
                                    : Colors.brown,
                          )
                        : Text('${index + 1}'),
                  ),
                  title: Text(
                    emailPrefix,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '${entry.completedCount} cursos',
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                );
              },
            ),
    );
  }
}
