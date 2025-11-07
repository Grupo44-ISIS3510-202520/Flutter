import 'package:flutter/material.dart';

class LabeledText extends StatelessWidget {
  const LabeledText({super.key, required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: Colors.grey[600]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: muted),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
