import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

abstract class ChatRepository {
  /// Fetches a real-time stream of chat rooms for the current user.
  Stream<Either<Failure, List<ChatRoomEntity>>> getChatRooms();

  /// Fetches a real-time stream of messages for a specific chat room.
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId);

  /// Sends a new message (text or file) to a chat room.
// Update the abstract method
Future<Either<Failure, void>> sendMessage({
  required String chatRoomId,
  required MessageEntity message,
  required UserEntity patient,
  required DoctorEntity doctor,
});
  /// Uploads a file to Firebase Storage and returns the download URL.
  Future<Either<Failure, String>> uploadFile(File file, String chatRoomId);
}