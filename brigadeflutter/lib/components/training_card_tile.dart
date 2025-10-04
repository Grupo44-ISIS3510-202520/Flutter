import 'package:flutter/material.dart';
import '../blocs/training/training_models.dart';

class TrainingCardTile extends StatelessWidget {
  final TrainingCard card;
  final VoidCallback onPressed;
  final bool loading;
  const TrainingCardTile({super.key, required this.card, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(card.imageUrl, width: 72, height: 72, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(card.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: loading ? null : onPressed,
                      child: loading
                          ? const SizedBox(width:16, height:16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(card.cta),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}