

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/models/doctor_model.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/domain/repository/doctor_profile_update_repository.dart';

class DoctorProfileUpdateRepositoryImpl extends DoctorProfileUpdateRepository{
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
   DoctorProfileUpdateRepositoryImpl(this._firestore,this._storage,this._auth);
@override
Future<Either<Failure, DoctorEntity>> doctorUpdateProfile(
    DoctorEntity doctor, File? imageFile) async {
  try {
    // 1. User Authentication Check (No changes here)
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Left(
          ServerFailure("User not authenticated. Please login again."));
    }

    // 2. Image Upload Logic (No changes here)
    String photoUrl = doctor.photoUrl;
    if (imageFile != null) {
      final ref = _storage.ref().child('doctor_profiles/$uid.jpg');
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
    await _firestore.collection('doctors').doc(uid).update(doctorMap);

    // 4. Updated Data ko waapas Fetch karna (No major changes here)
    final updatedDocSnapshot =
        await _firestore.collection('doctors').doc(uid).get();

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
