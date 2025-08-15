import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/data/models/appointment_model.dart';
import 'package:health_connect/features/auth/data/models/json_user.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/entity/appointment_detail_entity.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/repository/appointment_detail_repository.dart';

class AppointmentDetailRepositoryImpl implements AppointmentDetailRepository {
  final FirebaseFirestore _firestore;

  AppointmentDetailRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, AppointmentDetailEntity>> getAppointmentDetails(
    String appointmentId,
  ) async {
    try {
      // Step 1: Fetch the main appointment document
      final appointmentDoc = await _firestore.collection('appointments').doc(appointmentId).get();
      if (!appointmentDoc.exists) {
        return Left(FirestoreFailure("Appointment not found."));
      }
      final appointment = AppointmentModel.fromSnapshot(appointmentDoc).toDomain();
      final patientId = appointment.patientId;

      // Step 2: Fetch the associated patient's document
      final patientDoc = await _firestore.collection('users').doc(patientId).get();
      if (!patientDoc.exists) {
        return Left(FirestoreFailure("Patient associated with this appointment not found."));
      }
      final patient = UserModel.fromSnapshot(patientDoc).toDomain();

      // Step 3: Fetch the patient's recent visit history (e.g., last 5 completed)
      final historySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: appointment.doctorId)
          .where('status', whereIn: ['completed', 'no-show'])
          .orderBy('appointmentDateTime', descending: true)
          .limit(5)
          .get();
      
      final recentVisits = historySnapshot.docs
          .map((doc) => AppointmentModel.fromSnapshot(doc).toDomain())
          .toList();

      // Step 4: Combine all data into a single entity
      final appointmentDetail = AppointmentDetailEntity(
        appointment: appointment,
        patient: patient,
        recentVisits: recentVisits,
      );

      return Right(appointmentDetail);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure("Firebase error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }
}