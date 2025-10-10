import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brigadeflutter/blocs/profile/profile_cubit.dart';
import 'package:brigadeflutter/blocs/profile/profile_state.dart';
import '../components/labeled_text.dart';
import '../components/app_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.loading || state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final p = state.profile!;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: const Text('Brigadist Profile'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(blurRadius: 10, color: Colors.black12)
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: p.availableNow ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  p.availableNow ? 'Available now' : 'Unavailable',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Switch.adaptive(
                                value: p.availableNow,
                                onChanged: state.updating
                                    ? null
                                    : (v) => context.read<ProfileCubit>().toggleAvailability(v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.person, color: Colors.white, size: 48),
                          ),
                          const SizedBox(height: 16),
                          LabeledText(label: 'Name', value: p.name),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LabeledText(label: 'Blood type', value: p.bloodType),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LabeledText(label: 'RH', value: p.rh),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LabeledText(
                            label: 'Time availability',
                            value: p.timeSlots.join(' · '),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'REWARDS',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: p.medals.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(blurRadius: 8, color: Colors.black12)
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.military_tech),
                          const SizedBox(width: 12),
                          Expanded(child: Text(p.medals[i])),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.read<ProfileCubit>().updateAvailabilityBasedOnLocation();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Availability updated based on current location'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.location_on),
        label: const Text('Auto update'),
      ),

      bottomNavigationBar: const AppBottomNav(current: 4),
    );
  }
}
