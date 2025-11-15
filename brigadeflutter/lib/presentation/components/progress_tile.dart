import 'package:flutter/material.dart';
import '../../data/entities/training_progress.dart';

class ProgressTile extends StatelessWidget {
  const ProgressTile({super.key, required this.progress});
  final TrainingProgress progress;

  @override
  Widget build(BuildContext context) {
    final double percent = progress.percent / 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const <BoxShadow>[
            BoxShadow(blurRadius: 6, color: Colors.black12),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
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
                  children: <Widget>[
                    const Icon(Icons.star,
                        size: 14, color: Color(0xFF2F6AF6)), 
                    const SizedBox(width: 4),
                    Text(
                      '${progress.percent}%',
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
