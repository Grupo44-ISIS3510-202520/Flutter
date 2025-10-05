import 'package:flutter/material.dart';
import '../components/app_bottom_nav.dart';

class EmergencyDashboardScreen extends StatelessWidget {
  const EmergencyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: const Text(
          "Emergency Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
            },
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
              
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 18),
                      
                      // Emergency Button
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
                              padding: EdgeInsets.all(constraints.maxWidth * 0.12), 
                              elevation: 0, 
                            ),
                            onPressed: () {
                      
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_active, 
                                  color: Colors.white, 
                                  size: constraints.maxWidth * 0.08,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "EMERGENCY",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: constraints.maxWidth * 0.032,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: availableHeight * 0.04), 
                      
                      // Four Buttons
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.9,
                        children: [
                          _DashboardCard(
                            icon: Icons.notifications,
                            label: "Notifications",
                            onTap: () => Navigator.pushNamed(context, '/notification'),
                          ),
                          _DashboardCard(
                            icon: Icons.menu_book,
                            label: "Protocols",
                            onTap: () => Navigator.pushNamed(context, '/protocols'),
                          ),
                          _DashboardCard(
                            icon: Icons.school,
                            label: "Training",
                            onTap: () => Navigator.pushNamed(context, '/training'),
                          ),
                          _DashboardCard(
                            icon: Icons.person,
                            label: "Profile",
                            onTap: () => Navigator.pushNamed(context, '/profile'),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: availableHeight * 0.02), 
                      
                      // CPR Guide Button
                      GestureDetector(
                        onTap: () {
                        },
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
                              Icon(Icons.favorite, color: Colors.pink, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "CPR Guide",
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
                      
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue[600]),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}