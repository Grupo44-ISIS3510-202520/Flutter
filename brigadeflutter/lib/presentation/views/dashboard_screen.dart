import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/routes.dart';
import '../components/app_bottom_nav.dart';
import '../components/dashboard_action_tile.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../navigation/dashboard_commands.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (_, vm, __) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text(
              'Emergency Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => Navigator.pushNamed(context, routeReport),
              ),
            ],
          ),
          bottomNavigationBar: const AppBottomNav(current: 0),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final emergencyCmd = vm.emergency as GoEmergencyReportCommand;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: availableHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 18),

                          // Botón grande de emergencia
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: const CircleBorder(),
                                  padding: EdgeInsets.all(constraints.maxWidth * 0.2),
                                  elevation: 0,
                                ),
                                onPressed: () => emergencyCmd.execute(context),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: Colors.white,
                                      size: constraints.maxWidth * 0.1,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'EMERGENCY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: constraints.maxWidth * 0.04,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Punto de Encuentro (CAS)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Punto de encuentro más cercano',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: ElevatedButton(
                                        onPressed: vm.isFinding
                                            ? null
                                            : () => vm.updateNearestMeetingPoint(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.zero,
                                          elevation: 0,
                                        ),
                                        child: vm.isFinding
                                            ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                            : const Icon(Icons.refresh, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  vm.nearestLabel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: vm.isOutsideCampus
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: vm.locationAvailable
                                        ? (vm.isOutsideCampus
                                        ? Colors.orange[700]
                                        : Colors.black)
                                        : Colors.red,
                                  ),
                                  softWrap: true,
                                ),
                                if (vm.nearestSubtext.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    vm.nearestSubtext,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                    softWrap: true,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.4,
                            children: vm.actions
                                .map((cmd) => DashboardActionTile(command: cmd))
                                .toList(),
                          ),

                          SizedBox(height: availableHeight * 0.02),

                          // Guía de RCP 
                          GestureDetector(
                            onTap: () => vm.cprGuide.execute(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.favorite,
                                      color: Colors.pink, size: 28),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'CPR Guide',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      color: Colors.grey, size: 16),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
