import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

abstract class DoctorProfileViewState extends Equatable {
  const DoctorProfileViewState();
  @override
  List<Object> get props => [];
}

class DoctorProfileInitial extends DoctorProfileViewState {}
class DoctorProfileLoading extends DoctorProfileViewState {}

class DoctorProfileLoaded extends DoctorProfileViewState {
  final DoctorEntity doctor;
  const DoctorProfileLoaded(this.doctor);
  
  @override
  List<Object> get props => [doctor];
}

class DoctorProfileError extends DoctorProfileViewState {
  final String message;
  const DoctorProfileError(this.message);
  
  @override
  List<Object> get props => [message];
}