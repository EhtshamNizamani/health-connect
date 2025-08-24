
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/patient/medical_info/domain/repository/update_patient_medical_info_repository.dart';

class UpdatePatientMedicalInfoUseCase implements UseCase<void, UserEntity> {
  final UpdatePatientMedicalInfoRepository repository;

  UpdatePatientMedicalInfoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UserEntity params) async {
    return await repository.updatePatientMedicalInfo(params);
  }
}