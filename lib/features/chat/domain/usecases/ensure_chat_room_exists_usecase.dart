import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class EnsureChatRoomExistsUseCase {
  final ChatRepository repository;
  EnsureChatRoomExistsUseCase(this.repository);
  
  Future<Either<Failure, String>> call(String chatRoomId, UserEntity patient, DoctorEntity doctor) {
    return repository.ensureChatRoomExists(chatRoomId, patient, doctor);
  }
}