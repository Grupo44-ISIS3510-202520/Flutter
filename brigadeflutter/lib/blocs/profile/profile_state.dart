import 'package:equatable/equatable.dart';
import 'profile_models.dart';

class ProfileState extends Equatable {
  final BrigadistProfile? profile;
  final bool loading, updating;

  const ProfileState({this.profile, this.loading = false, this.updating = false});

  ProfileState copyWith({BrigadistProfile? profile, bool? loading, bool? updating}) =>
      ProfileState(profile: profile ?? this.profile, loading: loading ?? this.loading, updating: updating ?? this.updating);

  @override
  List<Object?> get props => [profile, loading, updating];
}