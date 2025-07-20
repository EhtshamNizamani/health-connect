import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

Future<Either<AuthFailure, UserEntity>> call({required String email, required String password}) {
    return _authRepository.login(email: email, password: password);
  }

 
}
