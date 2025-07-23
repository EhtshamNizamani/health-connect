import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}

class AuthenticatedPatient extends AuthState {
  final UserEntity user;
   AuthenticatedPatient(this.user);
  @override
  List<Object> get props => [user];
}

class AuthenticatedDoctorProfileExists extends AuthState {
  final UserEntity user;
   AuthenticatedDoctorProfileExists(this.user);
  @override
  List<Object> get props => [user];
}

class AuthenticatedDoctorProfileNotExists extends AuthState {
  final UserEntity user;
   AuthenticatedDoctorProfileNotExists(this.user);
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}
