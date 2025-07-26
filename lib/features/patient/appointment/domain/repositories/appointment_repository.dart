import 'package:dartz/dartz.dart';

import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/patient/appointment/domain/entities/appointment_entity.dart';

abstract class AppointmentRepository {
  // Method to create a new appointment
  Future<Either<Failure, void>> bookAppointment(AppointmentEntity appointment);
  
  // Method to get booked appointment start times for a doctor on a specific day
  Future<Either<Failure, List<DateTime>>> getBookedSlots(String doctorId, DateTime date);
  
  // We can add more methods later, e.g., getMyAppointments(String userId)
}