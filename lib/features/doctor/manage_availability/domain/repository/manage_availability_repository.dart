import 'package:dartz/dartz.dart';
import 'package:health_connect/core/data/entities/daily_availability_entity.dart';
import 'package:health_connect/core/error/failures.dart';

abstract class ManageAvailabilityRepository {
  Future<Either<Failure, void>> saveDoctorAvailability(
     Map<String, DailyAvailability>  weeklyAvailability,
 );
}