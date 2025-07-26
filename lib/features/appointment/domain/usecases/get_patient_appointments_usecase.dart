import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';

class GetPatientAppointmentsUseCase {
  final AppointmentRepository repository;
  GetPatientAppointmentsUseCase(this.repository);

  Future<Either<Failure,List<AppointmentEntity>>> call(String patientId)async{
    return await repository.getPatientAppointments(patientId);
  }
}