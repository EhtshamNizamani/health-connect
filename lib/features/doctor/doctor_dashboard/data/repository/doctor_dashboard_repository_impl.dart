import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/data/models/appointment_model.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/domain/repository/doctor_dashboard_repository.dart' show DoctorDashboardRepository;

class DoctorDashboardRepositoryImpl implements DoctorDashboardRepository {
  final FirebaseFirestore _firestore;
  DoctorDashboardRepositoryImpl(this._firestore);
  
  @override
  Stream<Either<Failure, List<AppointmentEntity>>> getDoctorAppointmentsStream(String doctorId) {
    try {
      final snapshots = _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .snapshots();
      
      return snapshots.map((querySnapshot) {
        final allAppointments = querySnapshot.docs
            .map((doc) => AppointmentModel.fromSnapshot(doc).toDomain())
            .toList();
        return Right<Failure, List<AppointmentEntity>>(allAppointments);
      });
    } catch (e) {
      return Stream.value(Left(FirestoreFailure("...")));
    }
  }
}