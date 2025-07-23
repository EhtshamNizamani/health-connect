import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/models/doctor_model.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_entity.dart';

import '../../domain/repositories/doctor_repository.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  DoctorRepositoryImpl(this.firestore, this.storage, this.auth);

  @override
  Future<Either<DoctorProfileFailure, void>> saveDoctorProfile(DoctorEntity doctor, File? imageFile) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return Left(DoctorProfileFailure("User not authenticated"));

    String photoUrl = doctor.photoUrl; // Default URL lein
    if (imageFile != null) {
      final ref = storage.ref().child('doctor_profiles/$uid.jpg');
      await ref.putFile(imageFile);
      photoUrl = await ref.getDownloadURL();
    }

    // 1. Pehle Entity ko Model mein convert karein
    final doctorModel = DoctorModel.fromEntity(doctor);

    // 2. Ab Model par copyWith use karein
    final updatedDoctorModel = doctorModel.copyWith(
      uid: uid,
      photoUrl: photoUrl,
    );

    // 3. Model se Map banayein
    final doctorMap = updatedDoctorModel.toMap();

    // 4. Firestore mein save karein
    await firestore.collection('doctors').doc(uid).set(doctorMap);
    return Right(null);
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
        return Right(DoctorModel.fromMap(docSnapshot.data()!));
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
      // 1. User Authentication Check
      final uid = auth.currentUser?.uid;
      if (uid == null) {
        return Left(
            ServerFailure( "User not authenticated. Please login again."));
      }

      // 2. Image Upload Logic (agar nayi image hai)
      String photoUrl = doctor.photoUrl; // Purani photo URL ko default rakhein

      if (imageFile != null) {
        // Agar user ne nayi image chuni hai, to use Firebase Storage mein upload karein
        final ref = storage.ref().child('doctor_profiles/$uid.jpg');
        await ref.putFile(imageFile);
        
        // Nayi upload ki gayi image ka download URL haasil karein
        photoUrl = await ref.getDownloadURL();
      }

      // 3. Data ko Model mein Convert karna aur Update karna
      // Pehle Entity se Model banayein
      final doctorModel = DoctorModel.fromEntity(doctor);

      // Model ko nayi photo URL ke saath update karein
      final updatedDoctorModel = doctorModel.copyWith(photoUrl: photoUrl);
      
      // Model ko Map mein convert karein taaki Firestore mein save ho sake
      final doctorMap = updatedDoctorModel.toMap();

      // Firestore mein document ko .update() method se update karein
      await firestore.collection('doctors').doc(uid).update(doctorMap);

      // 4. Updated Data ko waapas Fetch karna
      // Update ke baad, document ko dobara fetch karein taaki hum latest data return kar sakein
      final updatedDocSnapshot =
          await firestore.collection('doctors').doc(uid).get();

      // Agar kisi wajah se document delete ho gaya ho (unlikely but possible)
      if (!updatedDocSnapshot.exists) {
        return Left(ServerFailure( "Failed to retrieve updated profile."));
      }
      
      // Fetch kiye gaye data se naya Model banayein
      final updatedDoctor = DoctorModel.fromMap(updatedDocSnapshot.data()!);

      // 5. Success Case: Updated Entity ko return karein
      // Model ek Entity hai, isliye seedha return kar sakte hain
      return Right(updatedDoctor);

    } on FirebaseException catch (e) {
      // Firebase se related specific errors ko handle karein
      return Left(ServerFailure( "Firebase Error: ${e.message}"));
    } catch (e) {
      // Baaki ke kisi bhi unexpected error ko handle karein
      return Left(ServerFailure( "An unknown error occurred: $e"));
    }
  }
}
