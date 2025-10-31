import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/leaderboard_viewmodel.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<LeaderboardViewModel>().loadLeaderboard());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeaderboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Leaderboard"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.entries.length,
              itemBuilder: (context, index) {
                final entry = vm.entries[index];
                final shortEmail = entry.email.split('@').first;
                final rank = index + 1;

                IconData? icon;
                Color? color;
                if (rank == 1) {
                  icon = Icons.emoji_events;
                  color = Colors.amber;
                } else if (rank == 2) {
                  icon = Icons.emoji_events;
                  color = Colors.grey;
                } else if (rank == 3) {
                  icon = Icons.emoji_events;
                  color = Colors.brown;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: icon != null
                        ? Icon(icon, color: color)
                        : Text("$rank", style: const TextStyle(color: Colors.black)),
                  ),
                  title: Text(shortEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${entry.completedCount} cursos completados"),
                );
              },
            ),
    );
  }
}