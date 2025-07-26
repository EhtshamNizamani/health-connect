import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';

class BookAppointmentUseCase {
  final AppointmentRepository repository;
  BookAppointmentUseCase(this.repository);

  Future<Either<Failure, void>> call(AppointmentEntity appointment) async {
    // You could add business logic here, e.g., check if the appointment time is in the past.
    return await repository.bookAppointment(appointment);
  }
}