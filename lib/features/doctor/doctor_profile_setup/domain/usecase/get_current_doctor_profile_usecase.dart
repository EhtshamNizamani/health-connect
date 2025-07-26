import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/repositories/doctor_profile_repository.dart';

class GetCurrentDoctorProfileUseCase {

  final DoctorProfileRepository _repository;

  GetCurrentDoctorProfileUseCase(this._repository);

   Future<Either<DoctorProfileFailure, DoctorEntity>> call(){
    return _repository.getCurrentDoctorProfile();
  }
}