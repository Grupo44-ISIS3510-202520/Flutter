import 'package:brigadeflutter/components/app_bar_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/emergency_report/emergency_report_cubit.dart';
import '../blocs/emergency_report/emergency_report_state.dart';
import '../components/app_bottom_nav.dart';
import '../components/protocol_search_field.dart';

class EmergencyReportScreen extends StatefulWidget {
  const EmergencyReportScreen({super.key});

  @override
  State<EmergencyReportScreen> createState() => _EmergencyReportScreenState();
}

class _EmergencyReportScreenState extends State<EmergencyReportScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyReportCubit, EmergencyReportState>(
      builder: (context, state) {
        final cubit = context.read<EmergencyReportCubit>();

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
                    decoration: const InputDecoration(hintText: 'Emergency Type'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: state.placeTime,
                    onChanged: cubit.onPlaceTimeChanged,
                    decoration: const InputDecoration(hintText: 'Place & Time'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: state.description,
                    onChanged: cubit.onDescriptionChanged,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(hintText: 'Description'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Switch(value: state.isFollowUp, onChanged: cubit.onFollowChanged),
                      const SizedBox(width: 8),
                      const Text('Follow-up report'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: state.submitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            await cubit.submit();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Report submitted')),
                            );
                          },
                    child: state.submitting
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
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
