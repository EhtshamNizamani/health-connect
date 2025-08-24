
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/data/models/appointment_model.dart';
import 'package:health_connect/features/auth/data/models/json_user.dart';
import 'package:health_connect/features/doctor/patient_details/domain/entity/patient_details_entity.dart';
import 'package:health_connect/features/doctor/patient_details/domain/repository/patient_details_repository.dart';

class PatientDetailRepositoryImpl implements PatientDetailRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PatientDetailRepositoryImpl(this._firestore, this._auth);

  @override
  Future<Either<Failure, PatientDetailEntity>> getPatientDetails(String patientId) async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) {
      return Left(AuthFailure("Doctor not authenticated."));
    }

    try {
      // Step 1: Fetch the patient's user document
      final patientDoc = await _firestore.collection('users').doc(patientId).get();
      if (!patientDoc.exists) {
        return Left(FirestoreFailure("Patient not found."));
      }
      final patient = UserModel.fromSnapshot(patientDoc).toDomain();

      // Step 2: Fetch all appointments between this patient and the doctor
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('appointmentDateTime', descending: true)
          .get();
      
      final allAppointments = appointmentsSnapshot.docs
          .map((doc) => AppointmentModel.fromSnapshot(doc).toDomain())
          .toList();

      // Step 3: Combine all data into the entity
      final patientDetail = PatientDetailEntity(
        patient: patient,
        allAppointments: allAppointments,
      );

      return Right(patientDetail);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure("Database error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }
}