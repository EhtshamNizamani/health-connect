import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;
  UpdateUserProfileUseCase(this.repository);
  
  Future<Either<AuthFailure, UserEntity>> call({
    required String uid,
    required String name,
    File? photoFile,
  }) async {
    return await repository.updateUserProfile(uid: uid, name: name, photoFile: photoFile);
  }
}