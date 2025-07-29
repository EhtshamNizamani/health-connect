import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type; // 'text', 'image', 'pdf'
  final Timestamp timestamp;
  final String? fileUrl;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [id, senderId, content, timestamp];
}