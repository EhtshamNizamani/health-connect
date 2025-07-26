import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';

class UpdateAppointmentsStatusUseCase {
  final AppointmentRepository repository;
  UpdateAppointmentsStatusUseCase(this.repository);

  Future<Either<Failure,void>> call(String appointmentId, String newStatus)async{
    return await repository.updateAppointmentStatus(appointmentId,newStatus);
  }
}