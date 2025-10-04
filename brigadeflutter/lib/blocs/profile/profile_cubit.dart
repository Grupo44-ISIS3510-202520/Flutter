import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repo;
  ProfileCubit(this.repo) : super(const ProfileState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final p = await repo.getProfile();
    emit(state.copyWith(profile: p, loading: false));
  }

  Future<void> toggleAvailability(bool v) async {
    emit(state.copyWith(updating: true));
    await repo.setAvailability(v);
    final p = await repo.getProfile();
    emit(state.copyWith(profile: p, updating: false));
  }
}