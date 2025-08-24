
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/patient_details/domain/entity/patient_details_entity.dart';

abstract class PatientDetailRepository {
  /// Fetches all data related to a single patient, including their
  /// user profile and their entire appointment history with the doctor.
  Future<Either<Failure, PatientDetailEntity>> getPatientDetails(String patientId);
}