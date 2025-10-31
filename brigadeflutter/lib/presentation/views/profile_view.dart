import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/app_bar_actions.dart';
import '../components/labeled_text.dart';
import '../components/app_bottom_nav.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../data/entities/brigadist_profile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final authUser = FirebaseAuth.instance.currentUser;

    if (authUser != null && !vm.isLoading && vm.profile == null) {
      Future.microtask(() => vm.load(authUser.uid));
    }

    if (vm.isLoading || vm.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final p = vm.profile!;
    final isBrigadist = p.role.toLowerCase() == 'brigadist';
    final brigadist = p is BrigadistProfile ? p : null;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text('User Profile'),
              leading: backToDashboardButton(context),
              actions: [
                signOutAction(context), 
              ],
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
                      BoxShadow(blurRadius: 10, color: Colors.black12),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (isBrigadist && brigadist != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: brigadist.availableNow ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                brigadist.availableNow ? 'Available now' : 'Unavailable',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Switch.adaptive(
                              value: brigadist.availableNow,
                              onChanged: vm.isUpdating
                                  ? null
                                  : (v) => vm.toggleAvailability(v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.person, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 16),

                      LabeledText(label: 'Name', value: '${p.name} ${p.lastName}'),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: LabeledText(label: 'Blood type', value: p.bloodGroup),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LabeledText(label: 'Role', value: p.role),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LabeledText(label: 'Email', value: p.email),

                      if (isBrigadist &&
                          brigadist != null &&
                          brigadist.timeSlots.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        LabeledText(
                          label: 'Time availability',
                          value: brigadist.timeSlots.join(' · '),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            if (brigadist != null && brigadist.medals.isNotEmpty) ...[
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
                itemCount: brigadist.medals.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(blurRadius: 8, color: Colors.black12),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.military_tech),
                        const SizedBox(width: 12),
                        Expanded(child: Text(brigadist.medals[i])),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),

      floatingActionButton: (isBrigadist && brigadist != null)
          ? FloatingActionButton.extended(
              onPressed: () async {
                await vm.updateAvailabilityBasedOnLocation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Availability updated based on current location'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Auto update'),
            )
          : null,

      bottomNavigationBar: const AppBottomNav(current: 4),
    );
  }
}