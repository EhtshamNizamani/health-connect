import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/entity/appointment_detail_entity.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/repository/appointment_detail_repository.dart';

class GetAppointmentDetailsUseCase implements UseCase<AppointmentDetailEntity, String> {
  final AppointmentDetailRepository repository;

  GetAppointmentDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, AppointmentDetailEntity>> call(String appointmentId) async {
    return await repository.getAppointmentDetails(appointmentId);
  }
}