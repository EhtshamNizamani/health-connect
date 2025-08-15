import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

abstract class DoctorDashboardRepository {
  // Yeh ab sirf AppointmentEntity ki stream dega
  Stream<Either<Failure, List<AppointmentEntity>>> getDoctorAppointmentsStream(String doctorId);
}