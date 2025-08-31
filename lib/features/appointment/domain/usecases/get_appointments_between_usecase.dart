import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';

class GetAppointmentsBetweenUseCase {
  final AppointmentRepository repository;
  GetAppointmentsBetweenUseCase(this.repository);

  Future<Either<Failure, List<AppointmentEntity>>> call(String patientId, String doctorId) {
    return repository.getAppointmentsBetween(patientId, doctorId);
  }
}