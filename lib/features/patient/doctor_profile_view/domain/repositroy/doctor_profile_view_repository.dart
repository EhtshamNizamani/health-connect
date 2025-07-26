import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

abstract class DoctorProfileViewRepository {

  Future<Either<Failure, DoctorEntity>> getDoctorById(String id);
  Future<Either<Failure, List<DateTime>>> getAvailableSlots(String doctorId, DateTime date);
}
