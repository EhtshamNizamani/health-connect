import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/models/doctor_model.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/patient/doctor_list/domain/repositories/doctor_repository.dart';

class FirebaseDoctorRepositoryImpl implements DoctorRepository {
  final FirebaseFirestore _firestore;
  FirebaseDoctorRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<DoctorEntity>>> getDoctors() async {
    try {
      final querySnapshot = await _firestore.collection('doctors').get();
      final List<DoctorEntity> doctors = querySnapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data()).toDomain())
          .toList();
      return Right(doctors);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch doctors: $e'));
    }
  }
}
