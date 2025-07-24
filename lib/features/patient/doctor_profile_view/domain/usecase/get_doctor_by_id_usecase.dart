
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/repositroy/doctor_profile_view_repository.dart';

class GetDoctorByIdUseCase {
  final DoctorProfileViewRepository repository;

  GetDoctorByIdUseCase(this.repository);

  Future<Either<Failure, DoctorEntity>> call(String id) async {
    return await repository.getDoctorById(id);
  }
}