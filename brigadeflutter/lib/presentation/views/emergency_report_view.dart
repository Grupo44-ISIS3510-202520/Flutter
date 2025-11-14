import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/utils/input_formatters.dart';
import '../../core/utils/validators.dart';
import '../components/app_bar_actions.dart';
import '../components/app_bottom_nav.dart';
import '../components/banner_report_offline.dart';
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

  @override
  void initState() {
    super.initState();
    _typeCtrl = TextEditingController();
    _placeCtrl = TextEditingController();
    _descCtrl = TextEditingController();

    // inicializa el cas de brillo sin notificar durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final EmergencyReportViewModel vm = context.read<EmergencyReportViewModel>();
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
        if (_placeCtrl.text != vm.placeTime && vm.placeTime.isNotEmpty) {
          _placeCtrl.text = vm.placeTime;
        }

        final bool isOnline = vm.isOnline ?? !vm.offline;

        return Scaffold(
          appBar: AppBar(
            leading: backToDashboardButton(context),
            title: const Text('Emergency Report'),
            actions: <Widget>[signOutAction(context)],
          ),
          bottomNavigationBar: const AppBottomNav(current: 0),

          body: Column(
            children: <Widget>[
              if (vm.offline) const OfflineMaterialBanner(),
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

                        if (vm.autoBrightnessSupported) ...<Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.brightness_auto, size: 20),
                                const SizedBox(width: 8),
                                const Text('Auto brightness'),
                                const Spacer(),
                                Switch(
                                  value: vm.autoBrightnessOn,
                                  onChanged:
                                      vm.toggleAutoBrightness, // delega al vm
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        TextFormField(
                          controller: _typeCtrl,
                          onChanged: vm.onTypeChanged,
                          decoration: const InputDecoration(
                            hintText: 'Emergency Type',
                          ),
                          inputFormatters: <TextInputFormatter>[SafeTextFormatter(max: 60)],
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
                          onChanged: vm.onPlaceTimeChanged,
                          decoration: const InputDecoration(hintText: 'Place'),
                          inputFormatters: <TextInputFormatter>[SafeTextFormatter(max: 100)],
                          maxLength: 100,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          buildCounter:
                              (
                                _, {
                                required int currentLength,
                                required bool isFocused,
                                int? maxLength,
                              }) => kNoCounter,
                          validator: validatePlaceTime,
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
                                    _placeCtrl.text = vm.placeTime;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added location'),
                                      ),
                                    );
                                  } else {
                                    _placeCtrl.text = vm.placeTime;
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

                        if (vm.latitude != null && vm.longitude != null) ...<Widget>[
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
                          controller: _descCtrl,
                          onChanged: vm.onDescriptionChanged,
                          minLines: 4,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'Description',
                          ),
                          inputFormatters: <TextInputFormatter>[SafeTextFormatter(max: 500)],
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
                          onPressed: vm.submittingReport
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  final int? id = await vm.submit(isOnline: isOnline);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        id != null
                                            ? 'Report submitted (id: #$id)'
                                            : 'Error submitting report :( We will save it locally and try again later',
                                      ),
                                    ),
                                  );
                                  if (id != null) {
                                    // limpia UI tras éxito
                                    _typeCtrl.clear();
                                    _placeCtrl.clear();
                                    _descCtrl.clear();
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
