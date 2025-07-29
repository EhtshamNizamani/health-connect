import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed to determine the "other" user

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  
  // These fields are specific to the model and help create the entity
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String patientPhotoUrl;
  final String doctorPhotoUrl;
  
  const ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.patientPhotoUrl,
    required this.doctorPhotoUrl,
  });

  /// Creates a Model from a Firestore DocumentSnapshot.
  factory ChatRoomModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] as List? ?? []),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] as Timestamp? ?? Timestamp.now(),
      patientId: data['patientId'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      patientPhotoUrl: data['patientPhotoUrl'] as String? ?? '',
      doctorPhotoUrl: data['doctorPhotoUrl'] as String? ?? '',
    );
  }

  /// Converts the Model to a Map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'patientPhotoUrl': patientPhotoUrl,
      'doctorPhotoUrl': doctorPhotoUrl,
    };
  }

  /// Converts this Data Model to a Domain Entity.
  /// This is where the logic to determine the "other" user resides.
  ChatRoomEntity toDomain() {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    // Determine the other user's details based on the current user's role/ID
    final bool isPatient = currentUserUid == patientId;
    
    final String otherUserName = isPatient ? doctorName : patientName;
    final String otherUserPhotoUrl = isPatient ? doctorPhotoUrl : patientPhotoUrl;

    return ChatRoomEntity(
      id: id,
      participants: participants,
      lastMessage: lastMessage,
      lastMessageTimestamp: lastMessageTimestamp,
      otherUserName: otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl,
    );
  }
}