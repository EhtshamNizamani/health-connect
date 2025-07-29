import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/domain/repository/doctor_profile_update_repository.dart';

class DoctroProfileUpdateUseCase {
  final DoctorProfileUpdateRepository _repository;
  DoctroProfileUpdateUseCase(this._repository);

  Future<Either<Failure, DoctorEntity>> call(
    DoctorEntity doctor,
    File? imageFile,
  ) {
    return _repository.doctorUpdateProfile(doctor, imageFile);
  }
}
