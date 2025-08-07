import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Enum to represent the status of a message.
// This is part of your domain logic.
enum MessageStatus { sending, sent, failed }

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type; // 'text', 'image', 'pdf'
  final Timestamp timestamp;
  final String? fileUrl;
  final MessageStatus status; // <<<--- NEW FIELD

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.fileUrl,
    this.status = MessageStatus.sent, // Default is 'sent'
  });

  /// Creates a copy of this MessageEntity but with the given fields replaced with the new values.
  /// This is crucial for updating the state of an optimistic message.
  MessageEntity copyWith({
    String? id,
    MessageStatus? status,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: timestamp,
      fileUrl: fileUrl,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id, senderId, content, timestamp, status // Add status to props
  ];
}