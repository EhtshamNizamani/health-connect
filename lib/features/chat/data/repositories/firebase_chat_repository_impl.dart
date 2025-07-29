import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/data/models/chat_room_model.dart';
import 'package:health_connect/features/chat/data/models/message_model.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';

import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class FirebaseChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  FirebaseChatRepositoryImpl(this._firestore, this._auth, this._storage);

  @override
  Stream<Either<Failure, List<ChatRoomEntity>>> getChatRooms() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Return a stream that emits a single error
      return Stream.value(Left(AuthFailure('User not authenticated.')));
    }

    try {
      // Listen to real-time changes in the 'chats' collection
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        final chatRooms = snapshot.docs
            .map((doc) => ChatRoomModel.fromSnapshot(doc).toDomain())
            .toList();
        return Right(chatRooms);
      });
    } catch (e) {
      return Stream.value(Left(FirestoreFailure("Failed to fetch chat rooms: $e")));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true) // Get latest messages first
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs
            .map((doc) => MessageModel.fromSnapshot(doc).toDomain())
            .toList();
        return Right(messages);
      });
    } catch (e) {
      return Stream.value(Left(FirestoreFailure("Failed to fetch messages: $e")));
    }
  }

@override
Future<Either<Failure, void>> sendMessage({
  required String chatRoomId,
  required MessageEntity message,
  required UserEntity patient,
  required DoctorEntity doctor,
}) async {
  final currentUser = _auth.currentUser;
  if (currentUser == null) return Left(AuthFailure('User not authenticated.'));

  try {
    final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);
    final messageRef = chatRoomRef.collection('messages').doc();
    final messageModel = MessageModel.fromEntity(message);

    // Run a transaction to be safe
    await _firestore.runTransaction((transaction) async {
      final chatRoomDoc = await transaction.get(chatRoomRef);

      if (!chatRoomDoc.exists) {
        // --- THIS IS THE FIRST MESSAGE ---
        // Create the chat room document
        final chatRoomData = {
          'participants': [patient.id, doctor.uid],
          'lastMessage': message.content,
          'lastMessageTimestamp': message.timestamp,
          'patientId': patient.id,
          'doctorId': doctor.uid,
          'patientName': patient.name,
          'doctorName': doctor.name,
          'patientPhotoUrl': patient.photoUrl ?? '',
          'doctorPhotoUrl': doctor.photoUrl,
        };
        transaction.set(chatRoomRef, chatRoomData);
      } else {
        // --- THIS IS AN EXISTING CHAT ---
        // Just update the last message details
        transaction.update(chatRoomRef, {
          'lastMessage': message.type == 'text' ? message.content : 'Sent an attachment',
          'lastMessageTimestamp': message.timestamp,
        });
      }
      
      // In both cases, add the new message
      transaction.set(messageRef, messageModel.toMap());
    });

    return const Right(null);
  } catch (e) {
    return Left(FirestoreFailure("Failed to send message: $e"));
  }
}
  @override
  Future<Either<Failure, String>> uploadFile(File file, String chatRoomId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return Left(AuthFailure('User not authenticated.'));

      // Create a unique file name
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final storageRef = _storage.ref().child('chat_attachments/$chatRoomId/$fileName');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      
      return Right(downloadUrl);
    } catch (e) {
      return Left(StorageFailure("Failed to upload file: $e"));
    }
  }

}