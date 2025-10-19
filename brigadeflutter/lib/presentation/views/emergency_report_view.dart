import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/emergency_report_viewmodel.dart';
import '../../core/utils/validators.dart';
import '../components/app_bottom_nav.dart';
import '../components/app_bar_actions.dart';

class EmergencyReportScreen extends StatefulWidget {
  const EmergencyReportScreen({super.key});
  @override
  State<EmergencyReportScreen> createState() => _EmergencyReportScreenState();
}

class _EmergencyReportScreenState extends State<EmergencyReportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _usedGps = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyReportViewModel>(
      builder: (_, vm, __) {
        return Scaffold(
          appBar: AppBar(
            leading: backToDashboardButton(context),
            title: const Text('Emergency Report'),
            actions: [signOutAction(context)],
          ),
          bottomNavigationBar: const AppBottomNav(current: 0),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: vm.type,
                    onChanged: vm.onTypeChanged,
                    decoration: const InputDecoration(
                      hintText: 'Emergency Type',
                    ),
                    validator: (v) => requiredText(v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: vm.placeTime,
                    onChanged: vm.onPlaceTimeChanged,
                    decoration: const InputDecoration(hintText: 'Place'),
                    validator: (v) => requiredText(v),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use coordinates from GPS'),
                    onPressed: vm.submitting
                        ? null
                        : () async {
                            await vm.fillWithCurrentLocation();
                            setState(() => _usedGps = vm.latitude != null);
                            final ok = vm.latitude != null;
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Added location'
                                      : 'Enable location or GPS permissions',
                                ),
                              ),
                            );
                          },
                  ),
                  if (vm.latitude != null && vm.longitude != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Ubicación: ${vm.latitude!.toStringAsFixed(5)}, ${vm.longitude!.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: vm.description,
                    onChanged: vm.onDescriptionChanged,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(hintText: 'Description'),
                    validator: (v) => requiredText(v, max: 1000),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Switch(
                        value: vm.isFollowUp,
                        onChanged: vm.onFollowChanged,
                      ),
                      const SizedBox(width: 8),
                      const Text('Follow-up report'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.submitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final id = await vm.submit(isOnline: true);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  id != null
                                      ? 'Report submitted successfully. ID: #$id'
                                      : 'Error submitting report',
                                ),
                              ),
                            );
                          },
                    child: vm.submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Report'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
