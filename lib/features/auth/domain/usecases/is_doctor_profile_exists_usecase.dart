import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';

class IsDoctorProfileExistsUseCase {
  final AuthRepository repository;

  IsDoctorProfileExistsUseCase(this.repository);

  Future<Either<Failure, bool>> call(String uid) {
    return repository.isDoctorProfileExists(uid);
  }
}
