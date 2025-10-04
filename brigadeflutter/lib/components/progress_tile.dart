import 'package:flutter/material.dart';
import '../blocs/training/training_models.dart';

class ProgressTile extends StatelessWidget {
  final TrainingProgress progress;
  const ProgressTile({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = progress.percent / 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(blurRadius: 6, color: Colors.black12),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    progress.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 14, color: Color(0xFF2F6AF6)), 
                    const SizedBox(width: 4),
                    Text(
                      "${progress.percent}%",
                      style: const TextStyle(
                        color: Color(0xFF2F6AF6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF2F6AF6), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
