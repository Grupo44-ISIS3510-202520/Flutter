import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brigadeflutter/presentation/viewmodels/leaderboard_viewmodel.dart';
import '../components/connectivity_status_icon.dart';
import '../viewmodels/auth_viewmodel.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaderboardViewModel vm = context.watch<LeaderboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weekly Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: const <Widget>[ConnectivityStatusIcon()],
      ),
      backgroundColor: const Color(0xFFF3F5F8),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Consumer<AuthViewModel>(
                  builder: (_, authVM, __) {
                    if (!authVM.isOnline) {
                      final weekText = vm.cachedWeekId ?? "this week";

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.orange.shade100,
                        child: Text(
                          "You’re offline.\n\n"
                          "You’re viewing Week $weekText leaderboard.\n"
                          "Some results may be outdated until your connection is restored.\n"
                          "Remember it is updated every Sunday at 11:59 pm.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                Expanded(
                  child: ListView.builder(
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
                ),
              ],
            ),
    );
  }
}
