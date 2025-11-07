import 'user_profile.dart';

class BrigadistProfile extends UserProfile {
  const BrigadistProfile({
    required super.uid,
    required super.name,
    required super.lastName,
    required super.uniandesCode,
    required super.bloodGroup,
    required super.role,
    required super.email,
    this.availableNow = false,
    this.timeSlots = const [],
    this.medals = const [],
  });
  final bool availableNow;
  final List<String> timeSlots;
  final List<String> medals;

  BrigadistProfile copyWith({
    bool? availableNow,
    List<String>? timeSlots,
    List<String>? medals,
  }) {
    return BrigadistProfile(
      uid: uid,
      name: name,
      lastName: lastName,
      uniandesCode: uniandesCode,
      bloodGroup: bloodGroup,
      role: role,
      email: email,
      availableNow: availableNow ?? this.availableNow,
      timeSlots: timeSlots ?? this.timeSlots,
      medals: medals ?? this.medals,
    );
  }
}
