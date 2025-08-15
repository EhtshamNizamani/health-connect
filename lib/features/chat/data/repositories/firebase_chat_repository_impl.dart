import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/data/models/chat_room_model.dart';
import 'package:health_connect/features/chat/data/models/message_model.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:rxdart/rxdart.dart';
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
  Stream<Either<Failure, List<ChatRoomEntity>>> getChatRooms(String userId) {
    print("🔥 [Repo] getChatRooms stream is being created for user: $userId");
    try {
      // Create the stream from Firestore
      final snapshots = _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots();

      // Transform the stream with proper error handling
      return snapshots
          .map<Either<Failure, List<ChatRoomEntity>>>((snapshot) {
            print("✅ [Repo] getChatRooms stream emitted ${snapshot.docs.length} rooms.");
            
            try {
              final chatRooms = snapshot.docs
                  .map((doc) => ChatRoomModel.fromSnapshot(doc).toDomain())
                  .toList();

              return Right(chatRooms);
            } catch (e) {
              print("❌ [Repo] Error processing chat rooms: $e");
              return Left(FirestoreFailure("Error processing chat rooms: $e"));
            }
          })
          .onErrorReturn(Left(FirestoreFailure("Stream error in getChatRooms")))
          .startWith(const Right([]));
    } catch (e) {
      print("❌ [Repo] FAILED to create getChatRooms stream: $e");
      return Stream.value(
        Left(FirestoreFailure("Failed to fetch chat rooms: $e")),
      );
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map<Either<Failure, List<MessageEntity>>>((snapshot) {
            try {
              final messages = snapshot.docs
                  .map((doc) => MessageModel.fromSnapshot(doc).toDomain())
                  .toList();
              return Right(messages);
            } catch (e) {
              return Left(FirestoreFailure("Error processing messages: $e"));
            }
          })
          .onErrorReturn(Left(FirestoreFailure("Failed to fetch messages")));
    } catch (e) {
      return Stream.value(
        Left(FirestoreFailure("Failed to fetch messages: $e")),
      );
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
    if (currentUser == null) {
      return Left(AuthFailure('User not authenticated.'));
    }

    try {
      final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);
      final messageRef = chatRoomRef.collection('messages').doc();
      final messageModel = MessageModel.fromEntity(message);

      await _firestore.runTransaction((transaction) async {
        final chatRoomDoc = await transaction.get(chatRoomRef);

        if (!chatRoomDoc.exists) {
          // Create the chat room document for first message
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
            'unreadCount': {
              message.receiverId: 1,
              message.senderId: 0,
            },
          };
          transaction.set(chatRoomRef, chatRoomData);
        } else {
          // Update existing chat
          transaction.update(chatRoomRef, {
            'lastMessage': message.type == 'text'
                ? message.content
                : 'Sent an attachment',
            'lastMessageTimestamp': message.timestamp,
            'unreadCount.${message.receiverId}': FieldValue.increment(1),
          });
        }

        // Add the new message
        transaction.set(messageRef, messageModel.toMap());
      });

      return const Right(null);
    } catch (e) {
      print("❌ [Repo] Failed to send message: $e");
      return Left(FirestoreFailure("Failed to send message: $e"));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFile(
    File file,
    String chatRoomId,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure('User not authenticated.'));
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final storageRef = _storage.ref().child(
        'chat_attachments/$chatRoomId/$fileName',
      );

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      return Right(downloadUrl);
    } catch (e) {
      return Left(StorageFailure("Failed to upload file: $e"));
    }
  }

  @override
  Stream<Either<Failure, int>> getTotalUnreadCountStream(String userId) {
    try {
      print("🔥 [Repo] getTotalUnreadCountStream is being created for user: $userId");
      
      final snapshots = _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .snapshots();

      return snapshots
          .map<Either<Failure, int>>((snapshot) {
            print("✅ [Repo] getTotalUnreadCount stream emitted an update.");
            
            try {
              int totalUnread = 0;
              for (var doc in snapshot.docs) {
                final data = doc.data();
                final unreadData = data['unreadCount'] as Map<String, dynamic>? ?? {};
                final userUnreadCount = unreadData[userId] as int? ?? 0;
                totalUnread += userUnreadCount;
              }
              
              print("✅ [Repo] New total unread count is: $totalUnread");
              return Right(totalUnread);
            } catch (e) {
              print("❌ [Repo] Error calculating unread count: $e");
              return Left(FirestoreFailure("Error calculating unread count: $e"));
            }
          })
          .onErrorReturn(Left(FirestoreFailure("Stream error in getTotalUnreadCount")))
          .startWith(const Right(0));
    } catch (e) {
      print("❌ [Repo] FAILED to create getTotalUnreadCount stream: $e");
      return Stream.value(
        Left(FirestoreFailure("Failed to get total unread count: $e")),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markChatRoomAsRead(
    String chatRoomId,
    String userId,
  ) async {
    try {
      print("📖 [Repo] Marking chat room $chatRoomId as read for user $userId");
      
      await _firestore.collection('chats').doc(chatRoomId).update({
        'unreadCount.$userId': 0,
      });
      
      print("✅ [Repo] Successfully marked chat room as read");
      return const Right(null);
    } catch (e) {
      print("❌ [Repo] Failed to mark chat room as read: $e");
      return Left(FirestoreFailure("Failed to mark chat room as read: $e"));
    }
  }
}