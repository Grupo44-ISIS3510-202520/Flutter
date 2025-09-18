import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_notification.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState()) {
    loadMock();
  }

  // datos simulados
  Future<void> loadMock() async {
    emit(state.copyWith(loading: true));
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final mock = <AppNotification>[
      const AppNotification(
        title: 'Fire Alarm',
        subtitle: 'Critical Alert',
        timeLabel: 'Now',
        type: NotificationType.critical,
      ),
      const AppNotification(
        title: 'Injured Student',
        subtitle: 'Medical Emergency',
        timeLabel: '5 min ago',
        type: NotificationType.medical,
      ),
      const AppNotification(
        title: 'Suspicious Activity',
        subtitle: 'Security Alert',
        timeLabel: '30 min ago',
        type: NotificationType.security,
      ),
      const AppNotification(
        title: 'Upcoming Training',
        subtitle: 'Reminder',
        timeLabel: '1 hr ago',
        type: NotificationType.reminder,
      ),
      const AppNotification(
        title: 'Campus Closure',
        subtitle: 'General Announcement',
        timeLabel: '2 hrs ago',
        type: NotificationType.general,
      ),
    ];
    emit(NotificationsState(items: mock, loading: false));
  }
}
