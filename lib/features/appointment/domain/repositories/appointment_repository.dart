import 'package:dartz/dartz.dart';

import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

abstract class AppointmentRepository {
  // Method to create a new appointment
  Future<Either<Failure, void>> bookAppointment(AppointmentEntity appointment);
  
  // Method to get booked appointment start times for a doctor on a specific day
  Future<Either<Failure, List<DateTime>>> getBookedSlots(String doctorId, DateTime date);
  
  Stream<Either<Failure, List<AppointmentEntity>>> getDoctorAppointments(String doctorId);

  Stream<Either<Failure, List<AppointmentEntity>>> getPatientAppointments(String patientId);
  
  Future<Either<Failure, void>> updateAppointmentStatus(String appointmentId, String newStatus);
  
  Future<Either<Failure, String>> initiatePayment({
    required String doctorId,
    required int amount,
  });
}