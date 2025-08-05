import 'package:equatable/equatable.dart';

class VideoCallEntity extends Equatable {
  final String callId;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String receiverName;
  final String? receiverPhotoUrl;
  final VideoCallStatus status;
  final int durationSeconds;
  final DateTime createdAt;

  const VideoCallEntity({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    required this.receiverName,
    this.receiverPhotoUrl,
    required this.status,
    this.durationSeconds = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        callId,
        callerId,
        receiverId,
        callerName,
        receiverName,
        receiverPhotoUrl,
        status,
        durationSeconds,
        createdAt,
      ];

  VideoCallEntity copyWith({
    String? callId,
    String? callerId,
    String? receiverId,
    String? callerName,
    String? receiverName,
    String? receiverPhotoUrl,
    VideoCallStatus? status,
    int? durationSeconds,
    DateTime? createdAt,
  }) {
    return VideoCallEntity(
      callId: callId ?? this.callId,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      callerName: callerName ?? this.callerName,
      receiverName: receiverName ?? this.receiverName,
      receiverPhotoUrl: receiverPhotoUrl ?? this.receiverPhotoUrl,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum VideoCallStatus {
  initiating,
  connecting,
  ringing,
  connectingToCall,
  connected,
  ended,
  failed,
  busy,
  noAnswer,
  cancelled,
  declined,
}
