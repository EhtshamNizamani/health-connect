
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/patient/medical_info/domain/repository/update_patient_medical_info_repository.dart';

class UpdatePatientMedicalInfoRepositoryImpl implements UpdatePatientMedicalInfoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UpdatePatientMedicalInfoRepositoryImpl(this._firestore, this._auth);

  @override
  Future<Either<Failure, void>> updatePatientMedicalInfo(UserEntity updatedPatientData) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Left(AuthFailure("User not authenticated."));
    }

    try {
      // Create a map of only the fields we want to update.
      // We don't want to overwrite the whole document, just these specific fields.
      final dataToUpdate = {
        'allergies': updatedPatientData.allergies,
        'chronicConditions': updatedPatientData.chronicConditions,
        'age': updatedPatientData.age,
        'gender': updatedPatientData.gender,
      };

      await _firestore.collection('users').doc(currentUser.uid).update(dataToUpdate);
      
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure("Database error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }
}