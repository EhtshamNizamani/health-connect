

import 'package:equatable/equatable.dart';

abstract class PatientAppointmentsEvent extends Equatable {
  const PatientAppointmentsEvent();
  @override
  List<Object> get props => [];
}

// Event to fetch all appointments for the current patient
class FetchPatientAppointments extends PatientAppointmentsEvent {}

// Event for when a patient cancels an appointment
class CancelPatientAppointment extends PatientAppointmentsEvent {
  final String appointmentId;
  const CancelPatientAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}