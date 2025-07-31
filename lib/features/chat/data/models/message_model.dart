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
  // Note: The 'status' field does not exist in the model because
  // it is a UI-only state and is not stored in Firestore.

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
  /// 'status' is not included in the map.
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
  /// All messages coming from Firestore are considered 'sent'.
  MessageEntity toDomain() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: timestamp,
      fileUrl: fileUrl,
      status: MessageStatus.sent, // Messages from DB are always 'sent'
    );
  }

  /// Creates a Model from a Domain Entity.
  /// It ignores the entity's 'status' field.
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