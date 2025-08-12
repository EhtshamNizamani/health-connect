import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/features/notification/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl(this._firestore);

  @override
  Stream<Either<Failure, int>> getUnreadCountStream({
    required String userId,
    required String role,
  }) {
    try {
      Query query;
      if (role == 'doctor') {
        // A doctor's "unread" count is the number of pending appointments.
        query = _firestore
            .collection("appointments")
            .where("doctorId", isEqualTo: userId)
            .where("status", isEqualTo: "pending")
            .where("isReadByDoctor", isEqualTo: false);
      } else {
        // patient
        // A patient's "unread" count is the number of appointments whose
        // status has changed but they haven't seen it yet.
        query = _firestore
            .collection("appointments")
            .where("patientId", isEqualTo: userId)
            .where("isReadByPatient", isEqualTo: false);
      }

      // Map the stream of snapshots to a stream of counts
      return query.snapshots().map((snapshot) => Right(snapshot.docs.length));
    } catch (e) {
      return Stream.value(
        Left(FirestoreFailure("Failed to get notification stream: $e")),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationsAsRead({
    required String userId,
    required String role,
  }) async {
    try {
      if (role == 'patient') {
        // Find all unread appointments for the patient
        final querySnapshot = await _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .where('isReadByPatient', isEqualTo: false)
            .get();

        // Use a batch to update them all at once
        final batch = _firestore.batch();
        for (var doc in querySnapshot.docs) {
          batch.update(doc.reference, {'isReadByPatient': true});
        }
        await batch.commit();
      }else{
         // Find all unread appointments for the patient
        final querySnapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: userId)
            .where('isReadByDoctor', isEqualTo: false)
            .get();

        // Use a batch to update them all at once
        final batch = _firestore.batch();
        for (var doc in querySnapshot.docs) {
          batch.update(doc.reference, {'isReadByDoctor': true});
        }
        await batch.commit();
      }
      // For doctors, we don't need to "mark as read". The count automatically
      // decreases when they confirm/reject an appointment.
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure("Failed to mark notifications as read: $e"));
    }
  }
}
