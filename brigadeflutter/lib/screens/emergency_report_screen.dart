import 'package:brigadeflutter/components/app_bar_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brigadeflutter/services/analytics_service.dart' as analytics;

import '../blocs/emergency_report/emergency_report_cubit.dart';
import '../blocs/emergency_report/emergency_report_state.dart';
import '../components/app_bottom_nav.dart';
import '../components/protocol_search_field.dart';

import '../features/ai_voice_instructions.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';

class EmergencyReportScreen extends StatefulWidget {
  const EmergencyReportScreen({super.key});

  @override
  State<EmergencyReportScreen> createState() => _EmergencyReportScreenState();
}

class _EmergencyReportScreenState extends State<EmergencyReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _swSinceOpen = Stopwatch();
  bool _placeAlreadyTracked = false;
  bool _usedGps = false;
  final _swTotal = Stopwatch();

  @override
  void initState() {
    super.initState();
    _swSinceOpen.start();
    _swTotal.start();
    analytics.AnalyticsService.I.setUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyReportCubit, EmergencyReportState>(
      builder: (context, state) {
        final cubit = context.read<EmergencyReportCubit>();

        if (!_placeAlreadyTracked && state.placeTime.isNotEmpty) {
          final method = (state.latitude != null && state.longitude != null)
              ? 'gps'
              : 'manual';
          analytics.AnalyticsService.I.logReportPlaceFilled(
            method: method,
            ms: _swSinceOpen.elapsedMilliseconds,
          );
          _placeAlreadyTracked = true;
          _usedGps = method == 'gps';
        }

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
                  ProtocolSearchField(
                    value: state.protocolQuery,
                    onChanged: cubit.onProtocolChanged,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: state.type,
                    onChanged: cubit.onTypeChanged,
                    decoration: const InputDecoration(
                      hintText: 'Emergency Type',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: state.placeTime,
                    onChanged: cubit.onPlaceTimeChanged,
                    decoration: const InputDecoration(hintText: 'Place & Time'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar ubicación actual'),
                    onPressed: state.submitting
                        ? null
                        : () async {
                            await cubit.fillWithCurrentLocation();
                            _usedGps = cubit.state.latitude != null;

                            if (_usedGps &&
                                !_placeAlreadyTracked &&
                                cubit.state.placeTime.isNotEmpty) {
                              analytics.AnalyticsService.I.logReportPlaceFilled(
                                method: 'gps',
                                ms: _swSinceOpen.elapsedMilliseconds,
                              );
                              _placeAlreadyTracked = true;
                            }

                            if (!mounted) return;
                            final ok =
                                context
                                    .read<EmergencyReportCubit>()
                                    .state
                                    .latitude !=
                                null;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Ubicación agregada'
                                      : 'Activa permisos de ubicación o GPS',
                                ),
                              ),
                            );
                          },
                  ),

                  if (state.latitude != null && state.longitude != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Ubicación: ${state.latitude!.toStringAsFixed(5)}, ${state.longitude!.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: state.description,
                    onChanged: cubit.onDescriptionChanged,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(hintText: 'Description'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Switch(
                        value: state.isFollowUp,
                        onChanged: cubit.onFollowChanged,
                      ),
                      const SizedBox(width: 8),
                      const Text('Follow-up report'),
                    ],
                  ),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.record_voice_over),
                    label: const Text('Instrucciones (IA)'),
                    onPressed: () async {
                      final type = (state.type.isEmpty)
                          ? 'Emergencia'
                          : state.type;
                      final ai = AIVoiceInstructions(
                        openai: OpenAIService(),
                        tts: TtsService(),
                      );

                      try {
                        final text = await ai.run(type);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Instrucciones listas (${text.length} chars)',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error IA: $e')));
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: state.submitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            final ok = await cubit.submit();
                            final msTotal = _swTotal.elapsedMilliseconds;

                            await analytics.AnalyticsService.I
                                .logReportSubmitted(
                                  type: state.type,
                                  followUp: state.isFollowUp,
                                  usedGps: _usedGps,
                                  msTotal: msTotal,
                                );

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok ? 'Report submitted' : 'Error al enviar',
                                ),
                              ),
                            );

                            if (ok) {
                              // Resetea cronómetros y flags para la siguiente captura
                              _swSinceOpen
                                ..reset()
                                ..start();
                              _swTotal
                                ..reset()
                                ..start();
                              _placeAlreadyTracked = false;
                              _usedGps = false;
                            }
                          },
                    child: state.submitting
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
