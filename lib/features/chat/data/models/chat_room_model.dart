import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed to get the current user

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final Map<String, int> unreadCount; // <<< --- NAYI PROPERTY (MAP) ---

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
    required this.unreadCount, // <<< --- CONSTRUCTOR MEIN ADD KIYA ---
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

    // Safely read the unreadCount map from Firestore
    final unreadCountData = data['unreadCount'] as Map<String, dynamic>? ?? {};
    final unreadCountMap = unreadCountData.map((key, value) {
      // Ensure values are integers
      return MapEntry(key, value as int? ?? 0);
    });
    
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] as List? ?? []),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] as Timestamp? ?? Timestamp.now(),
      unreadCount: unreadCountMap, // <<< --- NAYI PROPERTY KO SET KIYA ---
      patientId: data['patientId'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      patientPhotoUrl: data['patientPhotoUrl'] as String? ?? '',
      doctorPhotoUrl: data['doctorPhotoUrl'] as String? ?? '',
    );
  }

  /// Converts the Model to a Map for writing to Firestore.
  /// Note: We usually don't need a toMap in the model if we're constructing the map for writes
  /// in the repository, but it can be useful.
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'unreadCount': unreadCount,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'patientPhotoUrl': patientPhotoUrl,
      'doctorPhotoUrl': doctorPhotoUrl,
    };
  }

  /// Converts this Data Model to a Domain Entity.
  /// This is where the logic to simplify data for the UI resides.
  ChatRoomEntity toDomain() {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    // Determine the other user's details
    final bool isPatient = currentUserUid == patientId;
    final String otherUserName = isPatient ? doctorName : patientName;
    final String otherUserPhotoUrl = isPatient ? doctorPhotoUrl : patientPhotoUrl;

    // <<< --- NAYA LOGIC YAHAN HAI ---
    // Get the unread count specifically for the CURRENT user
    final int unreadCountForCurrentUser = unreadCount[currentUserUid] ?? 0;

    return ChatRoomEntity(
      id: id,
      participants: participants,
      lastMessage: lastMessage,
      lastMessageTimestamp: lastMessageTimestamp,
      otherUserName: otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl,
      unreadCount: unreadCountForCurrentUser, // <<< --- NAYI PROPERTY KO SET KIYA ---
    );
  }
}