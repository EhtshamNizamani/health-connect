import 'package:equatable/equatable.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object> get props => [];
}

// Event to start the whole process: payment followed by booking
class PaymentAndBookingStarted extends BookingEvent {
  final AppointmentEntity appointmentDetails;

  const PaymentAndBookingStarted(this.appointmentDetails);

  @override
  List<Object> get props => [appointmentDetails];
}