import 'package:equatable/equatable.dart';

abstract class AppointmentDetailEvent extends Equatable {
  const AppointmentDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchAppointmentDetails extends AppointmentDetailEvent {
  final String appointmentId;
  const FetchAppointmentDetails(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}