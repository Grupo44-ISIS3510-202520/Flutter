import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final String message;

  const OfflineBanner({
    super.key,
    this.message = "Hey Uniandino, you’re offline! Reconnect to get all features back.",
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Card(
        color: Color(0xFFFFF3CD),
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Hey Uniandino, you’re offline! Reconnect to get all features back.",
            style: TextStyle(color: Color(0xFF856404)),
          ),
        ),
      ),
    );
  }
}
