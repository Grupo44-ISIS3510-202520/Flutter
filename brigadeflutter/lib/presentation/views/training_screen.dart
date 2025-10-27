import 'package:brigadeflutter/presentation/components/app_bar_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/training_viewmodel.dart';
import '../components/training_card_tile.dart';
import '../components/progress_tile.dart';
import '../components/app_bottom_nav.dart';

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
                children: [
                  // Cards
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      "First Aid",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...vm.cards.map(
                    (c) => TrainingCardTile(
                      card: c,
                      loading: vm.submitting,
                      onPressed: () => vm.onCtaPressed(c.id),
                    ),
                  ),

                  //Certificados pendientes 
                  if (vm.pendingCertificates.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        "Certificates pending",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ...vm.pendingCertificates
                        .map((p) => ProgressTile(progress: p)),
                  ],

                  //Certificados completados
                  if (vm.completedCertificates.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        "Certificates completed",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ...vm.completedCertificates
                        .map((p) => ProgressTile(progress: p)),
                  ],

                  const SizedBox(height: 24),
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
}
