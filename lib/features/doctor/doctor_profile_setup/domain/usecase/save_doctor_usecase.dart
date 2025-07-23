import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/repositories/doctor_repository.dart';


class SaveDoctorProfileUseCase {
  final DoctorRepository repository;

  SaveDoctorProfileUseCase(this.repository);

  Future<Either<DoctorProfileFailure, void>> saveDoctorProfile(DoctorEntity doctor, File? imageFile) {
    return repository.saveDoctorProfile(doctor, imageFile);
  }
  Future<Either<DoctorProfileFailure, DoctorEntity>> getCurrentDoctorProfile(){
    return repository.getCurrentDoctorProfile();
  }
  Future<Either<Failure,DoctorEntity>> updateDoctorProfile(DoctorEntity doctor, File? imageFile) {
    return repository.updateDoctorProfile(doctor, imageFile);
  }
}
