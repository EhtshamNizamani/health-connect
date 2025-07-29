import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call(String chatRoomId, MessageEntity message, UserEntity patient, DoctorEntity doctor) {
    // Provide appropriate values for patient and doctor as required by your application
    return repository.sendMessage(
      chatRoomId: chatRoomId,
      message: message,
      patient: patient,
      doctor: doctor,
    );
  }
}