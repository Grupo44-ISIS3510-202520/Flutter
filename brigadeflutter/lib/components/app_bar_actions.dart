
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//dashboard
IconButton backToDashboardButton(BuildContext context) {
  return IconButton(
    tooltip: 'Back to dashboard',
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    },
  );
}

// cerrar sesión con confirmación.
Widget signOutAction(BuildContext context, {bool confirm = true}) {
  return IconButton(
    tooltip: 'Sign out',
    icon: const Icon(Icons.logout),
    onPressed: () async {
      if (confirm) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sign out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign out')),
            ],
          ),
        );
        if (ok != true) return;
      }

      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    },
  );
}
