

import 'package:equatable/equatable.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

abstract class PatientAppointmentsState extends Equatable {
  const PatientAppointmentsState();
  @override
  List<Object> get props => [];
}

class PatientAppointmentsInitial extends PatientAppointmentsState {}
class PatientAppointmentsLoading extends PatientAppointmentsState {}
class PatientAppointmentsError extends PatientAppointmentsState {
  final String message;
  const PatientAppointmentsError(this.message);
  @override
  List<Object> get props => [message];
}

class PatientAppointmentsLoaded extends PatientAppointmentsState {
  final List<AppointmentEntity> upcoming;
  final List<AppointmentEntity> past;

  const PatientAppointmentsLoaded({
    required this.upcoming,
    required this.past,
  });
  
  @override
  List<Object> get props => [upcoming, past];
}