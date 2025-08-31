import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/patient/profile/domain/repositories/patient_profile_repository.dart';

class PatientProfileRepositoryImpl implements PatientProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PatientProfileRepositoryImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, String?>> updatePatientProfile({
    required String uid,
    required String name,
    File? photoFile,
    required String? allergies,
    required String? chronicConditions,
    required String? age,
    required String? gender,
  }) async {
    try {
      String? photoUrl;

      // Step 1: Upload new photo if it exists
      if (photoFile != null) {
        final ref = _storage.ref().child('profile_pictures/$uid/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(photoFile);
        photoUrl = await ref.getDownloadURL();
      }

      // Step 2: Prepare data for Firestore update
      final Map<String, dynamic> dataToUpdate = {
        'name': name,
        'allergies': allergies,
        'chronicConditions': chronicConditions,
        'age': age,
        'gender': gender,
      };
      
      // Only add photoUrl to the map if a new one was uploaded
      if (photoUrl != null) {
        dataToUpdate['photoUrl'] = photoUrl;
      }

      // Step 3: Update the user's document in Firestore
      await _firestore.collection('users').doc(uid).update(dataToUpdate);

      return Right(photoUrl); // Return the new photo URL if it was created
    } on FirebaseException catch (e) {
      return Left(StorageFailure("Failed to update profile: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }
}