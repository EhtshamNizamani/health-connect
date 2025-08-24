
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/doctor/patient_details/domain/entity/patient_details_entity.dart';
import 'package:health_connect/features/doctor/patient_details/domain/repository/patient_details_repository.dart';

class GetPatientDetailsUseCase implements UseCase<PatientDetailEntity, String> {
  final PatientDetailRepository repository;

  GetPatientDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, PatientDetailEntity>> call(String patientId) async {
    return await repository.getPatientDetails(patientId);
  }
}