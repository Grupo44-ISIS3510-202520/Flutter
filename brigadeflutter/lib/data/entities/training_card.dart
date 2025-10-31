import 'package:equatable/equatable.dart';

class TrainingCard extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String cta;

  const TrainingCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.cta,
  });

  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, cta];
}
