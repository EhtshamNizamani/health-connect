import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final String otherUserName; // Name of the person you are chatting with
  final String otherUserPhotoUrl;

  const ChatRoomEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.otherUserName,
    required this.otherUserPhotoUrl,
  });

  @override
  List<Object?> get props => [id, lastMessage, lastMessageTimestamp];
}