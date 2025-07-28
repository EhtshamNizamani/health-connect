import 'package:equatable/equatable.dart';

abstract class DoctorAppointmentsEvent extends Equatable {
  const DoctorAppointmentsEvent();
  @override
  List<Object> get props => [];
}

// Event to fetch all appointments for the doctor
class FetchDoctorAppointments extends DoctorAppointmentsEvent {}

// Event to confirm a pending appointment
class ConfirmAppointment extends DoctorAppointmentsEvent {
  final String appointmentId;
  const ConfirmAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}
class CompletedAppointment extends DoctorAppointmentsEvent {
  final String appointmentId;
  const CompletedAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}
// Event to cancel/reject an appointment
class CancelAppointment extends DoctorAppointmentsEvent {
  final String appointmentId;
  const CancelAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}