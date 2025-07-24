import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/models/doctor_model.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

import '../../domain/repositories/doctor_profile_repository.dart';

class FirebaseDoctorProfileRepositoryImpl implements DoctorProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  FirebaseDoctorProfileRepositoryImpl(this.firestore, this.storage, this.auth);

@override
Future<Either<Failure, void>> saveDoctorProfile(
    DoctorEntity doctor, File? imageFile) async {
  try {
    // 1. User Authentication Check
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      return Left(ServerFailure("User not authenticated. Please login again."));
    }

    // 2. Image Upload Logic (if an image is provided)
    String photoUrl = ''; // Start with an empty URL for a new profile
    if (imageFile != null) {
      final ref = storage.ref().child('doctor_profiles/$uid.jpg');
      await ref.putFile(imageFile);
      photoUrl = await ref.getDownloadURL();
    }

    // <<<--- THE MAIN CORRECTION IS HERE ---
    
    // 3. Convert the Domain Entity into a Data Model
    // The BLoC gives us a pure DoctorEntity. We need to convert it
    // into a DoctorModel to work with it in the data layer.
    final doctorModel = DoctorModel.fromEntity(doctor);

    // 4. Update the Model with data generated in this layer (uid, photoUrl)
    // We use copyWith to create a new, updated model instance.
    final finalDoctorModel = doctorModel.copyWith(
      uid: uid,
      photoUrl: photoUrl,
    );

    // 5. Convert the final Model to a Map for Firestore
    final doctorMap = finalDoctorModel.toMap();

    // 6. Save the data to Firestore using .set() for a new profile
    await firestore.collection('doctors').doc(uid).set(doctorMap);

    // 7. Return success (Right side of Either with void/null)
    return const Right(null);

  } on FirebaseException catch (e) {
    // Handle specific Firebase errors
    return Left(ServerFailure("Firebase Error: ${e.message}"));
  } catch (e) {
    // Handle any other unexpected errors
    return Left(ServerFailure("An unknown error occurred: $e"));
  }
}
  
  @override
  Future<Either<DoctorProfileFailure, DoctorEntity>> getCurrentDoctorProfile() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return Left(DoctorProfileFailure("User not authenticated"));

    try {
      final docSnapshot = await firestore.collection('doctors').doc(uid).get();
      if (docSnapshot.exists) {
        // Firestore se aaye Map ko DoctorModel mein convert karein
        // DoctorModel, DoctorEntity hai, isliye direct return kar sakte hain
        return Right(DoctorModel.fromMap(docSnapshot.data()!).toDomain());
      } else {
        return Left(DoctorProfileFailure("Doctor profile not found."));
      }
    } catch (e) {
      // Handle errors
      return Left(DoctorProfileFailure("Failed to fetch doctor profile: $e"));
    }
  }

  

@override
Future<Either<Failure, DoctorEntity>> updateDoctorProfile(
    DoctorEntity doctor, File? imageFile) async {
  try {
    // 1. User Authentication Check (No changes here)
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      return Left(
          ServerFailure("User not authenticated. Please login again."));
    }

    // 2. Image Upload Logic (No changes here)
    String photoUrl = doctor.photoUrl;
    if (imageFile != null) {
      final ref = storage.ref().child('doctor_profiles/$uid.jpg');
      await ref.putFile(imageFile);
      photoUrl = await ref.getDownloadURL();
    }

    // <<<--- CHANGE #1: Create DoctorModel from DoctorEntity ---
    // We need a way to convert the incoming Domain Entity into a Data Model.
    // Let's create a new factory constructor in DoctorModel for this.
    final doctorModel = DoctorModel.fromEntity(doctor);

    // Model ko nayi photo URL ke saath update karein
    final updatedDoctorModel = doctorModel.copyWith(photoUrl: photoUrl);
    
    // Model ko Map mein convert karein taaki Firestore mein save ho sake
    final doctorMap = updatedDoctorModel.toMap();

    // Firestore mein document ko .update() method se update karein
    await firestore.collection('doctors').doc(uid).update(doctorMap);

    // 4. Updated Data ko waapas Fetch karna (No major changes here)
    final updatedDocSnapshot =
        await firestore.collection('doctors').doc(uid).get();

    if (!updatedDocSnapshot.exists) {
      return Left(ServerFailure("Failed to retrieve updated profile."));
    }
    
    // Fetch kiye gaye data se naya Model banayein
    final fetchedDoctorModel = DoctorModel.fromMap(updatedDocSnapshot.data()!);

    // <<<--- CHANGE #2: Convert final Model back to Entity before returning ---
    // The repository's contract is to return a DoctorEntity.
    // We use .toDomain() to fulfill this contract.
    return Right(fetchedDoctorModel.toDomain());

  } on FirebaseException catch (e) {
    return Left(ServerFailure("Firebase Error: ${e.message}"));
  } catch (e) {
    return Left(ServerFailure("An unknown error occurred: $e"));
  }
}}
