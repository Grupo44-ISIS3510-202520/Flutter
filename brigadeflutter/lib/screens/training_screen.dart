import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/training/training_cubit.dart';
import '../blocs/training/training_state.dart';
import '../components/training_card_tile.dart';
import '../components/progress_tile.dart';


class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingCubit, TrainingState>(
      builder: (context, state) {
        if (state.status == UiStatus.loading) return const Center(child: CircularProgressIndicator());
        if (state.status == UiStatus.error) return const Center(child: Text('Error cargando training'));

        final theme = Theme.of(context);
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: const Text('Training'),
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('First Aid', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              SliverList.builder(
                itemCount: state.cards.length,
                itemBuilder: (_, i) => TrainingCardTile(
                  card: state.cards[i],
                  loading: state.submitting,
                  onPressed: () => context.read<TrainingCubit>().onCtaPressed(state.cards[i].id),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text('Your Progress', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              SliverList.builder(
                itemCount: state.progress.length,
                itemBuilder: (_, i) => ProgressTile(progress: state.progress[i]),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}