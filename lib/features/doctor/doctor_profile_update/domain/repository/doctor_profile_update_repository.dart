import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

abstract class DoctorProfileUpdateRepository {
  Future<Either<Failure,DoctorEntity>>doctorUpdateProfile(DoctorEntity doctor, File? imageFile);
}