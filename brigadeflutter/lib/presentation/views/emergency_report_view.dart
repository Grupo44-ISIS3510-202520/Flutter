import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../helpers/utils/input_formatters.dart';
import '../../helpers/utils/validators.dart';
import '../components/app_bar_actions.dart';
import '../components/app_bottom_nav.dart';
import '../components/banner_offline.dart';
import '../components/connectivity_status_icon.dart';
import '../viewmodels/emergency_report_viewmodel.dart';

class EmergencyReportScreen extends StatefulWidget {
  const EmergencyReportScreen({super.key});

  @override
  State<EmergencyReportScreen> createState() => _EmergencyReportScreenState();
}

class _EmergencyReportScreenState extends State<EmergencyReportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // controllers para limpiar campos tras submit
  late final TextEditingController _typeCtrl;
  late final TextEditingController _placeCtrl;
  late final TextEditingController _descCtrl;
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    _typeCtrl = TextEditingController();
    _placeCtrl = TextEditingController();
    _descCtrl = TextEditingController();

    // inicializa el cas de brillo sin notificar durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final EmergencyReportViewModel vm = context
          .read<EmergencyReportViewModel>();
      vm.initBrightness();
      vm.initConnectivityWatcher(); // no hace lógica en la vista
    });
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _placeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyReportViewModel>(
      builder: (_, EmergencyReportViewModel vm, __) {
        // sincroniza place cuando viene del gps
        if (_placeCtrl.text != vm.place && vm.place.isNotEmpty) {
          _placeCtrl.text = vm.place;
        }

        final bool isOffline = vm.offline;
        final bool isOnline = !isOffline;

        // Debug: print connectivity state
        debugPrint('EmergencyReportView build: vm.offline=$isOffline, vm.isOnline=${vm.isOnline}');

        return Scaffold(
          appBar: AppBar(
            leading: backToDashboardButton(context),
            title: const Text(
              'Emergency Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            actions: <Widget>[
              const ConnectivityStatusIcon(),
              signOutAction(context),
            ],
          ),
          bottomNavigationBar: const AppBottomNav(current: 0),

          body: Column(
            children: <Widget>[
              if (isOffline) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: OfflineBanner(),
                ),
              ],
              Expanded(
                child: SafeArea(
                  minimum: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _typeCtrl,
                          onChanged: vm.onTypeChanged,
                          decoration: const InputDecoration(
                            hintText: 'Emergency Type',
                          ),
                          inputFormatters: <TextInputFormatter>[
                            SafeTextFormatter(max: 60),
                          ],
                          maxLength: 60,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          buildCounter:
                              (
                                _, {
                                required int currentLength,
                                required bool isFocused,
                                int? maxLength,
                              }) => kNoCounter,
                          validator: (String? v) => requiredText(v),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _placeCtrl,
                          onChanged: vm.onPlaceChanged,
                          decoration: const InputDecoration(hintText: 'Place'),
                          inputFormatters: <TextInputFormatter>[
                            SafeTextFormatter(max: 100),
                          ],
                          maxLength: 100,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          buildCounter:
                              (
                                _, {
                                required int currentLength,
                                required bool isFocused,
                                int? maxLength,
                              }) => kNoCounter,
                          validator: validatePlace,
                        ),
                        const SizedBox(height: 8),

                        OutlinedButton.icon(
                          icon: const Icon(Icons.my_location),
                          label: vm.loadingLocation
                              ? const Text('Getting GPS...')
                              : const Text('Use coordinates from GPS'),
                          onPressed: vm.loadingLocation
                              ? null
                              : () async {
                                  final bool updated = await vm
                                      .fillWithCurrentLocation();
                                  if (!mounted) return;
                                  if (updated) {
                                    _placeCtrl.text = vm.place;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added location'),
                                      ),
                                    );
                                  } else {
                                    _placeCtrl.text = vm.place;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Enable location or GPS permissions',
                                        ),
                                      ),
                                    );
                                  }
                                },
                        ),

                        if (vm.latitude != null &&
                            vm.longitude != null) ...<Widget>[
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

                        OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            selectedTime == null
                              ? 'Select report date & time (optional)'
                              : 'Date: ${selectedTime!.day.toString().padLeft(2, '0')}/${selectedTime!.month.toString().padLeft(2, '0')}/${selectedTime!.year} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                          ),
                          onPressed: () async {
                            final DateTime initialDate = selectedTime ?? DateTime.now();
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              if (!mounted) return;
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(initialDate),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  selectedTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _descCtrl,
                          onChanged: vm.onDescriptionChanged,
                          minLines: 4,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'Description',
                          ),
                          inputFormatters: <TextInputFormatter>[
                            SafeTextFormatter(max: 500),
                          ],
                          maxLength: 500,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          buildCounter:
                              (
                                _, {
                                required int currentLength,
                                required bool isFocused,
                                int? maxLength,
                              }) => kNoCounter,
                          validator: validateDescription,
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: <Widget>[
                            Switch(
                              value: vm.isFollowUp,
                              onChanged: vm.onFollowChanged,
                            ),
                            const SizedBox(width: 8),
                            const Text('Follow-up report'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          icon: const Icon(Icons.record_voice_over),
                          label: vm.generatingVoice
                              ? const Text('Preparing...')
                              : const Text('Voice instructions'),
                          onPressed: vm.generatingVoice
                              ? null
                              : () async {
                                  await vm.onVoiceInstructions();
                                },
                        ),

                        ElevatedButton(
                          // onPressed: (vm.submittingReport || isOffline)
                          onPressed: vm.submittingReport
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  final String? reportId = await vm.submit(
                                    isOnline: isOnline,
                                    timestamp: selectedTime,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        reportId != null
                                            ? 'Report submitted (id: $reportId)'
                                            : 'Error submitting report :( We will save it locally and try again later',
                                      ),
                                    ),
                                  );
                                  if (reportId != null) {
                                    // limpia UI tras éxito
                                    _typeCtrl.clear();
                                    _placeCtrl.clear();
                                    _descCtrl.clear();
                                    setState(() {
                                      selectedTime = null;
                                    });
                                  }
                                },
                          child: vm.submittingReport
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Submit Report'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
