import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/data/models/appointment_model.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions; // <-- Firebase Functions ko inject karein

  AppointmentRepositoryImpl(
    this._firestore,
    this._functions,
  ); // <-- Constructor update karein

  @override
  Future<Either<Failure, void>> bookAppointment(
    AppointmentEntity appointment,
  ) async {
    // --- STEP 1: PREPARE FOR THE LOCK ---
    final appointmentsCollection = _firestore.collection('appointments');
    final locksCollection = _firestore.collection('appointment_locks');

    // Create a unique, predictable ID for the time slot lock
    final slotTime = appointment.appointmentDateTime;
    final lockId = '${appointment.doctorId}_${slotTime.millisecondsSinceEpoch}';
    final lockRef = locksCollection.doc(lockId);

    try {
      // --- STEP 2: ACQUIRE THE LOCK USING A TRANSACTION ---
      // This transaction only does one thing: it tries to create the lock document.
      // This is atomic and safe from race conditions.
      await _firestore.runTransaction((transaction) async {
        final lockDoc = await transaction.get(lockRef);

        // Check if the lock document already exists.
        if (lockDoc.exists) {
          // If it exists, someone else beat us to it. Fail the transaction.
          throw FirebaseException(
            plugin: 'firestore',
            code: 'aborted',
            message: 'This time slot was just booked. Please try another.',
          );
        }

        // If the lock does not exist, create it to claim the slot.
        transaction.set(lockRef, {'createdAt': FieldValue.serverTimestamp()});
      });

      // --- STEP 3: IF LOCK WAS ACQUIRED, CREATE THE REAL APPOINTMENT ---
      // If the transaction above succeeded, we now own the slot.
      // We can safely create the main appointment document.
      final appointmentModel = AppointmentModel.fromEntity(appointment);
      await appointmentsCollection.add(appointmentModel.toMap());

      // If everything succeeds, return success.
      return const Right(null);
    } on FirebaseException catch (e) {
      // Catch the specific error from the transaction if we lost the race.
      return Left(
        FirestoreFailure(e.message ?? 'This slot is no longer available.'),
      );
    } catch (e) {
      // Catch any other errors (e.g., creating the main appointment failed)
      // In a real app, you might want to delete the lock here if this part fails.
      return Left(
        FirestoreFailure("An unknown error occurred while booking: $e"),
      );
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getBookedSlots(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where(
            'appointmentDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'appointmentDateTime',
            isLessThan: Timestamp.fromDate(endOfDay),
          )
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

  @override
  Stream<Either<Failure, List<AppointmentEntity>>> getDoctorAppointments(
    String doctorId,
  ) {
    try {
      // Get the stream of snapshots from Firestore
      final snapshots = _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('appointmentDateTime', descending: true)
          .snapshots(); // <-- The key change: .get() becomes .snapshots()

      // Use .map to transform the stream of QuerySnapshots into a stream of our desired Either type
      return snapshots.map((querySnapshot) {
        final appointments = querySnapshot.docs
            .map((doc) => AppointmentModel.fromSnapshot(doc).toDomain())
            .toList();
        return Right<Failure, List<AppointmentEntity>>(appointments);
      });
    } catch (e) {
      // If setting up the stream fails, return a stream with a single error
      return Stream.value(
        Left(FirestoreFailure("Failed to listen to appointments: $e")),
      );
    }
  }

  // <<< --- NAYA STREAM-BASED METHOD FOR PATIENT ---
  @override
  Stream<Either<Failure, List<AppointmentEntity>>> getPatientAppointments(
    String patientId,
  ) {
    try {
      final snapshots = _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('appointmentDateTime', descending: true)
          .snapshots(); // <-- The key change

      return snapshots.map((querySnapshot) {
        final appointments = querySnapshot.docs
            .map((doc) => AppointmentModel.fromSnapshot(doc).toDomain())
            .toList();
        return Right<Failure, List<AppointmentEntity>>(appointments);
      });
    } catch (e) {
      return Stream.value(
        Left(FirestoreFailure("Failed to listen to appointments: $e")),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
      });
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure("Failed to update appointment status: $e"));
    }
  }

  @override
  Future<Either<Failure, String>> initiatePayment({
    required String doctorId,
    required int amount,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('createPayment');
      final response = await callable.call<Map<String, dynamic>>({
        'doctorId': doctorId,
        'amount': amount,
      });

      final clientSecret = response.data['clientSecret'] as String?;
      if (clientSecret != null) {
        
        return Right(clientSecret);
      } else {
        return Left(ServerFailure("Failed to get payment secret from server."));
      }
    } on FirebaseFunctionsException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'An error occurred with our server.'),
      );
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }
}
