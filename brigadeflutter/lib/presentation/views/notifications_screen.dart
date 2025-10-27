import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/notifications/notifications_cubit.dart';
import '../../blocs/notifications/notifications_state.dart';
import '../components/app_bottom_nav.dart';
import '../components/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            //onPressed: () => Navigator.of(context).maybePop(),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
            },
          ),
          title: const Text('Notifications'),
          centerTitle: true,
        ),
        bottomNavigationBar: const AppBottomNav(current: 3),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.items.isEmpty) {
                return const Center(child: Text('No notifications yet'));
              }
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, i) => NotificationTile(item: state.items[i]),
              );
            },
          ),
        ),
      ),
    );
  }
}