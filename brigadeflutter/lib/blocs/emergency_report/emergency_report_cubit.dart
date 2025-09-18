import 'package:flutter_bloc/flutter_bloc.dart';
import 'emergency_report_state.dart';

class EmergencyReportCubit extends Cubit<EmergencyReportState> {
  EmergencyReportCubit() : super(const EmergencyReportState());

  void onProtocolChanged(String v) => emit(state.copyWith(protocolQuery: v));
  void onTypeChanged(String v) => emit(state.copyWith(type: v));
  void onPlaceTimeChanged(String v) => emit(state.copyWith(placeTime: v));
  void onDescriptionChanged(String v) => emit(state.copyWith(description: v));
  void onFollowChanged(bool v) => emit(state.copyWith(isFollowUp: v));

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(submitting: true));
    await Future<void>.delayed(const Duration(milliseconds: 500)); // simulación
    // supongo que firebase
    emit(const EmergencyReportState()); // reset formulario
  }
}
