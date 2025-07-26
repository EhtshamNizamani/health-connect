import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/repositories/doctor_profile_repository.dart';

class UpdateDoctorProfileUseCase {

  final DoctorProfileRepository _repository;

  UpdateDoctorProfileUseCase(this._repository);

    Future<Either<Failure,DoctorEntity>> call(DoctorEntity doctor, File? imageFile) {
    return _repository.updateDoctorProfile(doctor, imageFile);
  }
}