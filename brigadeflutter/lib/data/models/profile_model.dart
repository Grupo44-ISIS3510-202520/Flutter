import 'package:equatable/equatable.dart';

class BrigadistProfile extends Equatable {
  final String name, bloodType, rh;
  final bool availableNow;
  final List<String> timeSlots, medals;

  const BrigadistProfile({
    required this.name,
    required this.bloodType,
    required this.rh,
    required this.availableNow,
    required this.timeSlots,
    required this.medals,
  });

  BrigadistProfile copyWith({
    String? name, String? bloodType, String? rh,
    bool? availableNow, List<String>? timeSlots, List<String>? medals,
  }) => BrigadistProfile(
      name: name ?? this.name,
      bloodType: bloodType ?? this.bloodType,
      rh: rh ?? this.rh,
      availableNow: availableNow ?? this.availableNow,
      timeSlots: timeSlots ?? this.timeSlots,
      medals: medals ?? this.medals,
    );

  @override
  List<Object?> get props => [name, bloodType, rh, availableNow, timeSlots, medals];
}