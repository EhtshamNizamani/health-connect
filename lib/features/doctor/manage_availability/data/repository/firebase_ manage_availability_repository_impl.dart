import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/data/entities/daily_availability_entity.dart';
import 'package:health_connect/core/data/model/daily_availability_model.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/manage_availability/domain/repository/manage_availability_repository.dart';

class FirebaseManageAvailabilityRepositoryImpl
    implements ManageAvailabilityRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseManageAvailabilityRepositoryImpl(this._firestore, this._firebaseAuth);
  @override
  Future<Either<Failure, void>> saveDoctorAvailability(
    Map<String, DailyAvailability> weeklyAvailability,
  ) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) return Left(ServerFailure("..."));

      // 1. Convert the Map of Entities to a Map of Maps
      final availabilityMapForFirestore = weeklyAvailability.map((day, dailyEntity) {
        // Convert each DailyAvailability Entity into a DailyAvailabilityModel
        final dailyModel = DailyAvailabilityModel.fromEntity(dailyEntity);
        // Convert the model to a map
        return MapEntry(day, dailyModel.toMap());
      });

      // 2. Update the single 'weeklyAvailability' field in the doctor's document
      await _firestore.collection('doctors').doc(uid).update({
        'weeklyAvailability': availabilityMapForFirestore,
      });

      return const Right(null); // Success!
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }}
