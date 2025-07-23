import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_entity.dart';
abstract class DoctorRepository {
  Future<Either<DoctorProfileFailure,void>> saveDoctorProfile(DoctorEntity doctor, File? imageFile);
  Future<Either<Failure,DoctorEntity>> updateDoctorProfile(DoctorEntity doctor, File? imageFile);
  Future<Either<DoctorProfileFailure,DoctorEntity>> getCurrentDoctorProfile();
}
