// lib/features/doctor_profile/presentation/bloc/doctor_profile_setup_state.dart

import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_entity.dart';

abstract class DoctorProfileSetupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DoctorProfileInitial extends DoctorProfileSetupState {}

class DoctorProfileLoading extends DoctorProfileSetupState {}

class DoctorProfileSuccess extends DoctorProfileSetupState {}
class DoctorProfileLoaded extends DoctorProfileSetupState {
  final DoctorEntity doctor;
   DoctorProfileLoaded(this.doctor);

  @override
  List<Object?> get props => [doctor];
}
class DoctorProfileFailure extends DoctorProfileSetupState {
  final String message;

  DoctorProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
