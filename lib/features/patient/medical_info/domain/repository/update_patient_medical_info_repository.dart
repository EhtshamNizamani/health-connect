import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

abstract class UpdatePatientMedicalInfoRepository {
  Future<Either<Failure, void>> updatePatientMedicalInfo(UserEntity updatedPatientData);
}