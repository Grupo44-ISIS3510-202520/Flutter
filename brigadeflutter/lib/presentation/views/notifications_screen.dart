import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// old NotificationScreenViewModel removed; using SimpleNotificationViewModel instead
import '../../../presentation/viewmodels/simple_notification_view_model.dart';
import 'package:brigadeflutter/app/di.dart' show sl;
import '../components/app_bottom_nav.dart';
import '../components/connectivity_status_icon.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _cacheDialogShown = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SimpleNotificationViewModel>(
      create: (_) => SimpleNotificationViewModel(
        dao: sl(),
        preferences: sl(),
      )..loadNotifications(),
      child: Consumer<SimpleNotificationViewModel>(
        builder: (context, vm, _) {
          // after load completes check cache info once and show dialog if needed
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (_cacheDialogShown) return;
            if (vm.isLoading) return;
            print('🖥️ [NotificationScreen] PostFrameCallback: vm.notifications.length = ${vm.notifications.length}');
            try {
              final Map<String, dynamic> info = await vm.getCacheInfo();
              print('🖥️ [NotificationScreen] Cache info received: $info');
              bool usedCache = false;
              if (info.isNotEmpty) {
                if (info['usedCache'] == true || info['fromCache'] == true) usedCache = true;
                if (!usedCache && info['cacheSize'] is int && info['cacheSize'] > 0) usedCache = true;
                if (!usedCache && info['count'] is int && info['count'] > 0) usedCache = true;
              }
              print('🖥️ [NotificationScreen] usedCache = $usedCache');
              if (usedCache && mounted) {
                _cacheDialogShown = true;
                print('🖥️ [NotificationScreen] Showing cache dialog');
                showDialog<void>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Offline data used'),
                    content: const Text(
                      'The notifications shown are loaded from cache because the device is offline or the server could not be reached.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dCtx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            } catch (_) {
              // ignore errors from cache info retrieval
            }
          });

          final alerts = vm.notifications;
          print('🖥️ [NotificationScreen] Building UI with ${alerts.length} alerts');

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.white,
              actions: const <Widget>[
                ConnectivityStatusIcon(),
              ],
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : (alerts.isEmpty
                    ? const _EmptyAlertsState()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListView.separated(
                          itemCount: alerts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            final alert = alerts[index];
                            return _NotificationCard(alert: alert);
                          },
                        ),
                      )),
            bottomNavigationBar: const AppBottomNav(current: 3),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.alert});
  final dynamic alert; // can be NotificationModel or NotificationEntity

  @override
  Widget build(BuildContext context) {
    // NotificationEntity now has .type field directly
    final String type = alert.type ?? 'info';
    final IconData iconData = _alertIcon(type);
    final Color bgColor = _alertColor(type);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showNotificationDialog(context, alert);
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
                      maxLines: 1,
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

  void _showNotificationDialog(BuildContext context, dynamic alert) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _alertIcon(alert.type),
                      color: Colors.black54,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  alert.message,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No active alerts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              "You'll be notified when new alerts are posted",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
