import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/training_viewmodel.dart';
import '../components/app_bottom_nav.dart';
import '../components/app_bar_actions.dart';
import '../../data/entities/training_card.dart';
import '../../data/entities/training_progress.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TrainingViewModel>().load());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TrainingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Training"),
        leading: backToDashboardButton(context),
      ),
      body: Builder(
        builder: (_) {
          switch (vm.status) {
            case UiStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case UiStatus.error:
              return const Center(child: Text("Error loading training"));
            case UiStatus.ready:
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildSection(
                    "Cursos en progreso",
                    vm.progress
                        .where((p) => p.percent > 0 && p.percent < 100)
                        .toList(),
                    vm,
                    vm.cards,
                  ),
                  _buildSection(
                    "Cursos completados",
                    vm.progress.where((p) => p.percent == 100).toList(),
                    vm,
                    vm.cards,
                  ),
                  _buildSection(
                    "Cursos disponibles",
                    vm.progress.where((p) => p.percent == 0).toList(),
                    vm,
                    vm.cards,
                  ),
                ],
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: const AppBottomNav(current: 1),
    );
  }

  Widget _buildSection(
    String title,
    List<TrainingProgress> progressList,
    TrainingViewModel vm,
    List<TrainingCard> cards,
  ) {
    if (progressList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...progressList.map((progress) {
          final card = cards.firstWhere(
            (c) => c.id == progress.id, 
            orElse: () => cards.first,
          );

          return KeyedSubtree(
            key: ValueKey(card.id), 
            child: _buildTrainingTile(card, progress, vm),
          );
        }),
      ],
    );
  }

  Widget _buildTrainingTile(
    TrainingCard card,
    TrainingProgress progress,
    TrainingViewModel vm,
  ) {
    final percent = progress.percent / 100.0;
    final inProgress = progress.percent > 0 && progress.percent < 100;
    final completed = progress.percent == 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  card.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Certification",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (inProgress || completed)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFF2F6AF6),
                        ),
                      ),
                    const SizedBox(height: 6),
                    if (!completed)
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: vm.submitting
                                ? null
                                : () => vm.onCtaPressed(card.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F6AF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              animationDuration:
                                  Duration(milliseconds: 0), // ✅ sin parpadeo
                            ),
                            child: Text(
                              inProgress ? "Avanzar" : "Iniciar curso",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (inProgress)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                "${progress.percent}%",
                                style: const TextStyle(
                                  color: Color(0xFF2F6AF6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      )
                    else
                      const Row(
                        children: [
                          Icon(Icons.star,
                              color: Color(0xFF2F6AF6), size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Completado",
                            style: TextStyle(
                              color: Color(0xFF2F6AF6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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