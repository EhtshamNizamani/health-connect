import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository{

  Future<Either<AuthFailure, UserEntity>> login({
    required String email,
    required String password,
  });
  Future<Either<AuthFailure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String selectedRole, // 'doctor' or 'patient'
  });
  Future<Either<AuthFailure, bool>> isDoctorProfileExists(String uid);
  Future<void> logout();

  Future<UserEntity?> getCurrentUser();

  Future<void> updateUser(UserEntity user);
}