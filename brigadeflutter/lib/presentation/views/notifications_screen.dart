import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/notification_model.dart';
import '../../../presentation/viewmodels/notification_screen_viewmodel.dart';
import '../components/app_bottom_nav.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationScreenViewModel viewModel = Provider.of<NotificationScreenViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: viewModel.notificationsStream,
        builder: (BuildContext context, AsyncSnapshot<List<NotificationModel>> snapshot) {
          final List<NotificationModel> alerts = snapshot.data ?? <NotificationModel>[];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (alerts.isEmpty) {
            return const _EmptyAlertsState();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.separated(
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final NotificationModel alert = alerts[index];
                return _NotificationCard(alert: alert);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(current: 3),
    );
  }
}

class _NotificationCard extends StatelessWidget {

  const _NotificationCard({required this.alert});
  final NotificationModel alert;

  @override
  Widget build(BuildContext context) {
    final IconData iconData = _alertIcon(alert.type);
    final Color bgColor = _alertColor(alert.type);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // optional analytics or navigation
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: Colors.black54, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeAgo(alert.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _alertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'emergency':
        return Icons.warning_amber_rounded;
      case 'medical':
        return Icons.health_and_safety_outlined;
      case 'security':
        return Icons.shield_outlined;
      case 'info':
        return Icons.menu_book_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _alertColor(String type) {
    switch (type.toLowerCase()) {
      case 'emergency':
        return const Color(0xFFFFE2E1);
      case 'medical':
        return const Color(0xFFEFF2F6);
      case 'security':
        return const Color(0xFFEFF2F6);
      case 'info':
        return const Color(0xFFEFF2F6);
      default:
        return const Color(0xFFEFF2F6);
    }
  }

  String _timeAgo(DateTime timestamp) {
    final Duration diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return DateFormat('dd MMM').format(timestamp);
  }
}
class _EmptyAlertsState extends StatelessWidget {
  const _EmptyAlertsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.warning_amber_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No active alerts',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              "You'll be notified when new alerts are posted",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}



// class NotificationsScreen extends StatelessWidget {
//   const NotificationsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<NotificationScreenViewModel>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: StreamBuilder<List<NotificationModel>>(
//         stream: viewModel.notificationsStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           final alerts = snapshot.data ?? [];
//           if (alerts.isEmpty) {
//             return const Center(child: Text('No notifications'));
//           }

//           return ListView.builder(
//             itemCount: alerts.length,
//             itemBuilder: (context, index) {
//               final alert = alerts[index];
//               return ListTile(
//                 leading: _buildIcon(alert.type),
//                 title: Text(alert.title),
//                 subtitle: Text(alert.message),
//                 trailing: Text(
//                   _timeAgo(alert.timestamp),
//                   style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 170, 53, 53)),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: const AppBottomNav(current: 3),
//     );
//   }

//   // icon based on alert type
//   Icon _buildIcon(String type) {
//     switch (type) {
//       case 'critical':
//         return const Icon(Icons.error, color: Colors.red);
//       case 'medical':
//         return const Icon(Icons.health_and_safety, color: Colors.green);
//       case 'security':
//         return const Icon(Icons.shield, color: Colors.blue);
//       case 'reminder':
//         return const Icon(Icons.campaign, color: Colors.purple);
//       default:
//         return const Icon(Icons.info_outline, color: Color.fromARGB(255, 221, 189, 189));
//     }
//   }
//     // time ago format
//   String _timeAgo(DateTime date) {
//     final diff = DateTime.now().difference(date);
//     if (diff.inMinutes < 1) return 'Now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
//     if (diff.inHours < 24) return '${diff.inHours} hr ago';
//     return '${diff.inDays} d ago';
//   }
// }
