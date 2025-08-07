import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';
class CallModel extends VideoCallEntity {
  const CallModel({
    required super.callId,
    required super.callerId,
    required super.receiverId,
    required super.callerName,
    required super.receiverName,
    super.receiverPhotoUrl,
    required super.status,
    required super.createdAt,
  });

  /// Creates a Model from a Firestore DocumentSnapshot.
  factory CallModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CallModel(
      callId: doc.id,
      // Ab hum nested user data se seedhe fields extract kar rahe hain.
      callerId: data['caller']?['id'] ?? '',
      callerName: data['caller']?['name'] ?? '',
      receiverId: data['receiver']?['id'] ?? '',
      receiverName: data['receiver']?['name'] ?? '',
      receiverPhotoUrl: data['receiver']?['photoUrl'],
      // Convert the status string from Firestore back to our enum
      status: VideoCallStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => VideoCallStatus.failed, // Fallback
      ),
      // Convert the Firestore Timestamp to DateTime
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  /// Converts the Model to a Map for writing to Firestore.
  Map<String, dynamic> toMap() {
    // toMap mein bhi hum data ko nested objects mein rakhenge,
    // kyunki Firestore is tarah ke structure ko asani se handle karta hai.
    return {
      'caller': {
        'id': callerId,
        'name': callerName,
      },
      'receiver': {
        'id': receiverId,
        'name': receiverName,
        'photoUrl': receiverPhotoUrl,
      },
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
