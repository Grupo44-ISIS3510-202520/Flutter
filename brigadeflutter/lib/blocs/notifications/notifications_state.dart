import 'package:equatable/equatable.dart';
import 'app_notification.dart';

class NotificationsState extends Equatable {
  final List<AppNotification> items;
  final bool loading;
  final String? error;

  const NotificationsState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

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
  List<Object?> get props => [items, loading, error];
}
