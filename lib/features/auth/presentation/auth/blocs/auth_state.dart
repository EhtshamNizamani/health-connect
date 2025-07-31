import 'package:equatable/equatable.dart';

import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

// Make the base class extend Equatable for consistency
abstract class AuthState extends Equatable {
  const AuthState();

  // <<<--- THIS IS THE MISSING GETTER ---
  /// A safe way to get the UserEntity from any authenticated state.
  /// Returns null if the state is not an authenticated state.
  UserEntity? get user {
    final state = this; // Use 'this' to refer to the current instance of the state
    if (state is AuthenticatedPatient) {
      return state.user;
    }
    if (state is AuthenticatedDoctorProfileExists) {
      return state.user;
    }
    if (state is AuthenticatedDoctorProfileNotExists) {
      return state.user;
    }
    // For any other state (Initial, Loading, Failure, Unauthenticated), return null.
    return null;
  }
  // <<<------------------------------------>>>

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthenticatedPatient extends AuthState {
  final UserEntity user;
  const AuthenticatedPatient(this.user);

  @override
  List<Object> get props => [user];
}

class AuthenticatedDoctorProfileExists extends AuthState {
  final UserEntity user;
  const AuthenticatedDoctorProfileExists(this.user);

  @override
  List<Object> get props => [user];
}

class AuthenticatedDoctorProfileNotExists extends AuthState {
  final UserEntity user;
  const AuthenticatedDoctorProfileNotExists(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}