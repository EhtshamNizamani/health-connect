import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/patient_records/domain/entity/patient_record_entity.dart';

abstract class PatientRecordsRepository {
  /// Fetches a list of all unique patients for a given doctor,
  /// along with the date of their last appointment.
  Future<Either<Failure, List<PatientRecordEntity>>> getPatientsForDoctor(String doctorId);
}