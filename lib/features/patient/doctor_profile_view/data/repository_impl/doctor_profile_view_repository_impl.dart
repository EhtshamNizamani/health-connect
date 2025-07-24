import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/models/doctor_model.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/repositroy/doctor_profile_view_repository.dart';

class DoctorProfileViewRepositoryImpl implements DoctorProfileViewRepository {
  final FirebaseFirestore _firestore;
  DoctorProfileViewRepositoryImpl(this._firestore);
  @override
  Future<Either<Failure, DoctorEntity>> getDoctorById(String id) async {
    try {
      final doctor = await _firestore.collection('doctors').doc(id).get();
      if (doctor.exists) {
        return Right(DoctorModel.fromMap(doctor.data()!).toDomain());
      } else {
        return Left(FirestoreFailure('Doctor not found'));
      }
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }
}
