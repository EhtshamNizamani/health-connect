import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';

abstract class PatientProfileRepository {
  /// Updates the patient's profile, including name, photo, and medical info.
  Future<Either<Failure, String?>> updatePatientProfile({
    required String uid,
    required String name,
    File? photoFile,
    required String? allergies,
    required String? chronicConditions,
    required String? age,
    required String? gender,
  });
}