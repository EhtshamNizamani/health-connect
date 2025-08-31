import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/patient/profile/domain/repositories/patient_profile_repository.dart';

class UpdatePatientProfileUseCase implements UseCase<String?, UpdatePatientProfileParams> {
  final PatientProfileRepository repository;

  UpdatePatientProfileUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(UpdatePatientProfileParams params) async {
    return await repository.updatePatientProfile(
      uid: params.uid,
      name: params.name,
      photoFile: params.photoFile,
      allergies: params.allergies,
      chronicConditions: params.chronicConditions,
      age: params.age,
      gender: params.gender,
    );
  }
}

class UpdatePatientProfileParams {
  final String uid;
  final String name;
  final File? photoFile;
  final String? allergies;
  final String? chronicConditions;
  final String? age;
  final String? gender;
  
  UpdatePatientProfileParams({
    required this.uid,
    required this.name,
    this.photoFile,
    this.allergies,
    this.chronicConditions,
    this.age,
    this.gender,
  });
}