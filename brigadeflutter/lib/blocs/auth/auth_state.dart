import 'package:equatable/equatable.dart';
class AuthState extends Equatable {
  final bool loading;
  final String? uid;
  final String? email;
  final String? error;
  const AuthState({this.loading=false, this.uid, this.email, this.error});
  AuthState copyWith({bool? loading, String? uid, String? email, String? error}) =>
    AuthState(loading: loading??this.loading, uid: uid??this.uid, email: email??this.email, error: error);
  @override List<Object?> get props => [loading, uid, email, error];
}
