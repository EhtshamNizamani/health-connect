import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/doctor/patient_records/domain/entity/patient_record_entity.dart';
import 'package:health_connect/features/doctor/patient_records/domain/repository/patient_records_repository.dart';

class GetPatientsForDoctorUseCase implements UseCase<List<PatientRecordEntity>, String> {
  final PatientRecordsRepository repository;

  GetPatientsForDoctorUseCase(this.repository);

  @override
  Future<Either<Failure, List<PatientRecordEntity>>> call(String doctorId) async {
    return await repository.getPatientsForDoctor(doctorId);
  }
}