import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/domain/repository/edit_appointment_summary_repository.dart';

class UpdateAppointmentSummaryUseCase implements UseCase<void, AppointmentEntity> {
  final EditAppointmentSummaryRepository repository;

  UpdateAppointmentSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AppointmentEntity params) async {
    return await repository.updateAppointmentSummary(params);
  }
}