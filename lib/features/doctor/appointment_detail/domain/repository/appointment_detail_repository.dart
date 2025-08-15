import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/entity/appointment_detail_entity.dart';

abstract class AppointmentDetailRepository {
  /// Fetches all the necessary details for a single appointment, including
  /// the appointment itself, patient data, and their recent visit history.
  Future<Either<Failure, AppointmentDetailEntity>> getAppointmentDetails(
    String appointmentId,
  );
}