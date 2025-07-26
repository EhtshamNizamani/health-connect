import 'package:equatable/equatable.dart';
import 'package:health_connect/features/patient/appointment/domain/entities/appointment_entity.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object> get props => [];
}

class AppointmentBookingRequested extends BookingEvent {
  final AppointmentEntity appointment;

  const AppointmentBookingRequested(this.appointment);
  
  @override
  List<Object> get props => [appointment];
}