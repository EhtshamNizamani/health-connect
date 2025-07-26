import 'package:dartz/dartz.dart';
import 'package:health_connect/core/data/entities/daily_availability_entity.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/manage_availability/domain/repository/manage_availability_repository.dart';

class SaveDoctorAvailabilityUseCase {

  final ManageAvailabilityRepository _repository;

  SaveDoctorAvailabilityUseCase(this._repository);
  Future<Either<Failure, void>> call(Map<String, DailyAvailability> weeklyAvailability) async {
    return await _repository.saveDoctorAvailability( weeklyAvailability);
  }
}