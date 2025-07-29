import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type;
  final Timestamp timestamp;
  final String? fileUrl;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.fileUrl,
  });

  /// Creates a Model from a Firestore DocumentSnapshot.
  factory MessageModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      type: data['type'] as String? ?? 'text',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      fileUrl: data['fileUrl'] as String?,
    );
  }

  /// Converts the Model to a Map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'timestamp': timestamp,
      'fileUrl': fileUrl,
    };
  }
  
  /// Converts this Data Model to a Domain Entity.
  MessageEntity toDomain() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: timestamp,
      fileUrl: fileUrl,
    );
  }

  /// Creates a Model from a Domain Entity.
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      content: entity.content,
      type: entity.type,
      timestamp: entity.timestamp,
      fileUrl: entity.fileUrl,
    );
  }
}