import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/data/models/json_user.dart';
import 'package:health_connect/features/doctor/patient_records/domain/entity/patient_record_entity.dart';
import 'package:health_connect/features/doctor/patient_records/domain/repository/patient_records_repository.dart';

class PatientRecordsRepositoryImpl implements PatientRecordsRepository {
  final FirebaseFirestore _firestore;

  PatientRecordsRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<PatientRecordEntity>>> getPatientsForDoctor(String doctorId) async {
    try {
      // Step 1: Get all appointments for this doctor to find unique patient IDs.
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('appointmentDateTime', descending: true)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        return const Right([]); // No appointments, so no patients yet.
      }

      // Step 2: Extract unique patient IDs and their last visit date.
      final Map<String, DateTime> patientLastVisitMap = {};
      for (final doc in appointmentsSnapshot.docs) {
        final patientId = doc.data()['patientId'] as String;
        // Since the list is sorted by date descending, the first time we see a
        // patientId, it corresponds to their latest appointment.
        if (!patientLastVisitMap.containsKey(patientId)) {
          patientLastVisitMap[patientId] = (doc.data()['appointmentDateTime'] as Timestamp).toDate();
        }
      }
      final uniquePatientIds = patientLastVisitMap.keys.toList();
      
      // Step 3: Fetch the user details for each unique patient ID.
      // Firebase `whereIn` queries are limited to 30 items. If you expect more
      // patients, you would need to batch these requests. For now, this is fine.
      if (uniquePatientIds.isEmpty) {
        return const Right([]);
      }
      
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: uniquePatientIds)
          .get();

      final patientRecords = usersSnapshot.docs.map((doc) {
        final user = UserModel.fromSnapshot(doc).toDomain();
        return PatientRecordEntity(
          patient: user,
          lastVisit: patientLastVisitMap[user.id],
        );
      }).toList();

      return Right(patientRecords);

    } on FirebaseException catch (e) {
      return Left(FirestoreFailure("Firebase error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }
}