import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart'; // Reuse the same entity

abstract class DoctorProfileUpdateState extends Equatable {
  const DoctorProfileUpdateState();
  @override
  List<Object?> get props => [];
}

class DoctorProfileUpdateInitial extends DoctorProfileUpdateState {}

class DoctorProfileUpdateLoading extends DoctorProfileUpdateState {}

class DoctorProfileUpdateLoaded extends DoctorProfileUpdateState {
  final DoctorEntity doctor;
  const DoctorProfileUpdateLoaded(this.doctor);
  @override
  List<Object?> get props => [doctor];
}

class DoctorProfileUpdating extends DoctorProfileUpdateState {}

class DoctorProfileUpdateSuccess extends DoctorProfileUpdateState {}

class DoctorProfileUpdateFailure extends DoctorProfileUpdateState {
  final String message;
  const DoctorProfileUpdateFailure(this.message);
  @override
  List<Object?> get props => [message];
}