import 'package:equatable/equatable.dart';

class TrainingCard extends Equatable {
  const TrainingCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.cta,
  });
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String cta;

  @override
  List<Object?> get props => <Object?>[id, title, subtitle, imageUrl, cta];
}
