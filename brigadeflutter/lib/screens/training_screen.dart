import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/training/training_cubit.dart';
import '../blocs/training/training_state.dart';
import '../components/training_card_tile.dart';
import '../components/progress_tile.dart';
import '../components/app_bottom_nav.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Training"),
        leading: BackButton(color: Colors.black),
      ),
      body: BlocBuilder<TrainingCubit, TrainingState>(
        builder: (context, state) {
          if (state.status == UiStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == UiStatus.error) {
            return const Center(child: Text("Error loading training"));
          }

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text("First Aid",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              ...state.cards.map(
                (c) => TrainingCardTile(
                  card: c,
                  loading: state.submitting,
                  onPressed: () =>
                      context.read<TrainingCubit>().onCtaPressed(c.id),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text("Your Progress",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              ...state.progress.map((p) => ProgressTile(progress: p)),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(current: 1),
    );
  }
}
