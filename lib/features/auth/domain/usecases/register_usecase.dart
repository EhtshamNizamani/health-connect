import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart' show AuthFailure;
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _authRepository;

  RegisterUsecase(this._authRepository);

  Future<Either<AuthFailure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required String selectedRole,
  }) {
    return _authRepository.register(
      name: name,
      email: email,
      password: password,
      selectedRole: selectedRole
    );
  }
}