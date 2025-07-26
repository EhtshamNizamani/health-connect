import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/patient/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/patient/appointment/domain/repositories/appointment_repository.dart';

class BookAppointmentUseCase {
  final AppointmentRepository repository;
  BookAppointmentUseCase(this.repository);

  Future<Either<Failure, List<DateTime>>> call(String doctorId, DateTime date) async {
    // You could add business logic here, e.g., check if the appointment time is in the past.
    return await repository.getBookedSlots(doctorId,date);
  }
}