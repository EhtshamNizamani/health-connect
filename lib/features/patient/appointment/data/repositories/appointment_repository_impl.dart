import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/patient/appointment/data/models/appointment_model.dart';
import 'package:health_connect/features/patient/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/patient/appointment/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore _firestore;
  AppointmentRepositoryImpl(this._firestore);
  
  @override
  Future<Either<Failure, void>> bookAppointment(AppointmentEntity appointment) async {
    try {
      final appointmentModel = AppointmentModel.fromEntity(appointment);
      final appointmentMap = appointmentModel.toMap();
      
      await _firestore.collection('appointments').add(appointmentMap);
      
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(FirestoreFailure("Failed to book appointment: $e"));
    }
  }
  
  @override
  Future<Either<Failure, List<DateTime>>> getBookedSlots(String doctorId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointmentDateTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
          
      final bookedSlots = querySnapshot.docs.map((doc) {
        final timestamp = doc['appointmentDateTime'] as Timestamp;
        return timestamp.toDate();
      }).toList();
      
      return Right(bookedSlots);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }
}