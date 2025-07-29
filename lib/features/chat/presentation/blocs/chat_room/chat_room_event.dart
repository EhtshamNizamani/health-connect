import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();
  @override
  List<Object> get props => [];
}

class SubscribeToMessages extends ChatRoomEvent {
  final String chatRoomId;
  const SubscribeToMessages(this.chatRoomId);
}
// ... (other events)

// NEW EVENT
class SendFileMessage extends ChatRoomEvent {
  final String chatRoomId;
  final String receiverId;
  final File file;
  final String messageType; // 'image' or 'pdf'
  final UserEntity patient;
  final DoctorEntity doctor;

  const SendFileMessage({
    required this.chatRoomId,
    required this.receiverId,
    required this.file,
    required this.messageType,
    required this.patient,
    required this.doctor,
  });
}
class SendMessage extends ChatRoomEvent {
  final String chatRoomId;
  final MessageEntity message;
  final DoctorEntity doctor;
  final UserEntity patient;
  const SendMessage(this.chatRoomId, this.message, this.doctor, this.patient);
}
