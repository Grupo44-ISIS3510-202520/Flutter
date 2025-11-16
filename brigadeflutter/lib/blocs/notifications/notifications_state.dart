import 'package:equatable/equatable.dart';
import 'app_notification.dart';

class NotificationsState extends Equatable {

  const NotificationsState({
    this.items = const <AppNotification>[],
    this.loading = false,
    this.error,
  });
  final List<AppNotification> items;
  final bool loading;
  final String? error;

  NotificationsState copyWith({
    List<AppNotification>? items,
    bool? loading,
    String? error,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[items, loading, error];
}
