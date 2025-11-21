import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/routes.dart';
import '../components/app_bottom_nav.dart';
import '../components/connectivity_status_icon.dart';
import '../components/dashboard_action_tile.dart';
import '../navigation/dashboard_commands.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});


  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        final DashboardViewModel vm = context.read<DashboardViewModel>();
        vm.updateNearestMeetingPoint();
        _initialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (_, DashboardViewModel vm, __) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text(
              'Emergency Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            actions: <Widget>[
              const ConnectivityStatusIcon(),
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
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double availableHeight = constraints.maxHeight;
                  final GoEmergencyReportCommand emergencyCmd = vm.emergency as GoEmergencyReportCommand;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: availableHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 18),

                          // Botón grande de emergencia
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: <BoxShadow>[
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
                                  children: <Widget>[
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
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Expanded(
                                      child: Text(
                                        'Closest meeting point',
                                        style: TextStyle(
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
                                            : () => vm.forceRecalculate(),
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
                                if (vm.nearestSubtext.isNotEmpty) ...<Widget>[
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
                                .map((DashboardActionCommand cmd) => DashboardActionTile(command: cmd))
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
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: <Widget>[
                                  Icon(Icons.favorite, color: Colors.pink, size: 28),
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
                                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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
