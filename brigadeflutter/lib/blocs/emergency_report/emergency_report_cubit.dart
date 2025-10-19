// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'emergency_report_state.dart';
// import '../../services/location_service.dart';
// import '../../domain/repositories/report_repository.dart';

// class EmergencyReportCubit extends Cubit<EmergencyReportState> {
//   final LocationService _location;
//   final ReportRepository _repo;

//   EmergencyReportCubit(this._location, this._repo) : super(const EmergencyReportState());

//   void onProtocolChanged(String v) => emit(state.copyWith(protocolQuery: v));
//   void onTypeChanged(String v) => emit(state.copyWith(type: v));
//   void onPlaceTimeChanged(String v) => emit(state.copyWith(placeTime: v));
//   void onDescriptionChanged(String v) => emit(state.copyWith(description: v));
//   void onFollowChanged(bool v) => emit(state.copyWith(isFollowUp: v));

//   // gps
//   Future<void> fillWithCurrentLocation() async {
//     emit(state.copyWith(submitting: true));
//     final pos = await _location.current();
//     if (pos == null) {
//       emit(state.copyWith(submitting: false));
//       return;
//     }
//     final now = DateTime.now();
//     final label = 'Lat ${pos.latitude.toStringAsFixed(5)}, '
//         'Lon ${pos.longitude.toStringAsFixed(5)} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
//     emit(state.copyWith(
//       placeTime: label,
//       latitude: pos.latitude,
//       longitude: pos.longitude,
//       submitting: false,
//     ));
//   }

//   Future<bool> submit() async {
//     if (!state.isValid) return false;
//     emit(state.copyWith(submitting: true));
//     try {
//       await _repo.createEmergencyReport(
//         type: state.type,
//         placeTime: state.placeTime,
//         description: state.description,
//         isFollowUp: state.isFollowUp,
//         protocolQuery: state.protocolQuery,
//         latitude: state.latitude,
//         longitude: state.longitude,
//       );
//       emit(const EmergencyReportState()); // reset
//       return true;
//     } catch (_) {
//       emit(state.copyWith(submitting: false));
//       return false;
//     }
//   }
// }
