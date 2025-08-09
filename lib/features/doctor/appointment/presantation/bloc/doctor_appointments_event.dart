import 'package:equatable/equatable.dart';

abstract class DoctorAppointmentsEvent extends Equatable {
  const DoctorAppointmentsEvent();
  @override
  List<Object> get props => [];
}

class FetchDoctorAppointments extends DoctorAppointmentsEvent {}

class ConfirmAppointment extends DoctorAppointmentsEvent {
  final String appointmentId;
  const ConfirmAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}

class CancelAppointment extends DoctorAppointmentsEvent {
  final String appointmentId;
  const CancelAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}

class CompletedAppointment extends DoctorAppointmentsEvent {
  final String appointmentId;
  const CompletedAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}

// Internal event to clear loading state
class ClearLoadingState extends DoctorAppointmentsEvent {
  @override
  List<Object> get props => [];
}
class MarkAsNoShow extends DoctorAppointmentsEvent {
  final String appointmentId;
  const MarkAsNoShow(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}